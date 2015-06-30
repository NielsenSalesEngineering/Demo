//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 4/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

# pragma mark Standard View Controller Stuff
# pragma mark -

#import "ID3VideoViewController.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "NielsenAppApi/NielsenAppApi.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


NielsenAppApi *nielsenMeter = nil;
NSString *playerInfo;
NSString *assetInfo;


@interface ID3VideoViewController ()

@property (nonatomic, retain) AVPlayerViewController *avPlayerViewcontroller;

@end


@implementation ID3VideoViewController

@synthesize player, playerView, playerItem;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the Nielsen App SDK
    NSDictionary *nielsenConfig = @{
                                    @"appid": @"T6DABF79D-CE15-4A47-A201-4E7DFE0F7EF0",
                                    @"appversion": @"1.0",
                                    @"appname": @"SDK Demo",
                                    @"sfcode": @"uat"
                                    };
    NSData *jsonDataNielsenConfig = [NSJSONSerialization dataWithJSONObject:nielsenConfig options:0 error:nil];
    NSString *jsonStringNielsenConfig = [[NSString alloc] initWithBytes:[jsonDataNielsenConfig bytes] length:[jsonDataNielsenConfig length] encoding:NSUTF8StringEncoding];
    nielsenMeter = [[NielsenAppApi alloc] initWithAppInfo:jsonStringNielsenConfig delegate:self];
    
    // Configure the player
    NSDictionary *playerInfoDict = @{
                                 @"channelName": @"Video Demo",
                                 @"adModel": @"2",
                                 @"dataSrc": @"cms"
                                 };
    NSData *playerInfoData = [NSJSONSerialization dataWithJSONObject:playerInfoDict options:0 error:nil];
    playerInfo = [[NSString alloc] initWithBytes:[playerInfoData bytes] length:[playerInfoData length] encoding:NSUTF8StringEncoding];
    
    // Configure the asset
    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    NSDictionary *assetInfoDict = @{
                                @"type": @"content",
                                @"assetid": @"demo",
                                @"tv": @"true",
                                @"program": @"Demo Program",
                                @"title": @"Demo Episode",
                                @"category": @"test",
                                @"adModel": @"2",
                                @"dataSrc": @"cms",
                                @"segA": @"Segment A",
                                @"segB": @"Segment B",
                                @"segC": @"Segment C",
                                @"adobeID": @"AdobeID",
                                @"reportSuite": @"RS-123",
                                @"crossId1": @"CRSID-1",
                                @"crossId2": @"CRSID-2"
                                };
    NSData *assetInfoData = [NSJSONSerialization dataWithJSONObject:assetInfoDict options:0 error:nil];
    assetInfo = [[NSString alloc] initWithBytes:[assetInfoData bytes] length:[assetInfoData length] encoding:NSUTF8StringEncoding];

    // Configure an AVPlayerViewController
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:url];
    self.avPlayerViewcontroller = playerViewController;
    self.avPlayerViewcontroller.view.frame = self.view.frame;
    [self.view addSubview:playerViewController.view];
    self.view.autoresizesSubviews = TRUE;
    
    // Register Key Value Observers on status and rate.  Register currentItem.timedMetadata if using ID3
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    // Uncomment to check assets for ID3 encoded metadata
    // [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"currentItem.timedMetadata" options:0 context:nil];
    
    // Observe player every 2 seconds and update playheadPosition
    CMTime i = CMTimeMakeWithSeconds(2.0, NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    [self.avPlayerViewcontroller.player addPeriodicTimeObserverForInterval:i queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSLog(@"Update playhead position");
        CMTime t = [weakSelf.avPlayerViewcontroller.player currentTime];
        long position = CMTimeGetSeconds(t);
        [nielsenMeter playheadPosition:position];
    }];
    
    // Users can opt out
    NSLog(@"Opt out URL: %@", [nielsenMeter optOutURLString]);
}

- (void)notifyInActive:(NSNotification *)notification {
    NSLog(@"notifyInActive: %@", notification.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


# pragma mark -
# pragma mark Key Value Observation
# pragma mark -

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // Watch for rate changes to handle pauses in playback.  A rate of 0 is paused.
    if ([path isEqualToString:@"rate"]) {
        if ([self.avPlayerViewcontroller.player rate]) {
            NSLog(@"Unpaused.");
            [nielsenMeter play:playerInfo];
            [nielsenMeter loadMetadata:assetInfo];
        } else {
            NSLog(@"Paused.");
            [nielsenMeter stop];
        }
        
    // Watch status to play asset once loaded
    } else if ([path isEqualToString:@"status"]) {
        if (self.avPlayerViewcontroller.player.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"Ready to play");
            [self.avPlayerViewcontroller.player play];
            [nielsenMeter play:playerInfo];
        }
        
    // Parse ID3 Tags and send to Nielsen App API
    } else if ([path isEqualToString:@"currentItem.timedMetadata"]) {
        NSLog(@"Parsing ID3 content.");
        for (AVMetadataItem *metadataItem in [[player currentItem] timedMetadata]) {
            id extraAttributeType = [metadataItem extraAttributes];
            NSString *extraString = nil;
            if ([extraAttributeType isKindOfClass:[NSDictionary class]]) {
                extraString = [extraAttributeType valueForKey:@"info"];
            }
            else if ([extraAttributeType isKindOfClass:[NSString class]]) {
                extraString = extraAttributeType;
            }
            if ([(NSString *)[metadataItem key] isEqualToString:@"PRIV"] && [extraString rangeOfString:@"www.nielsen.com"].length > 0) {
                if ([[metadataItem value] isKindOfClass:[NSData class]]) {
                    [nielsenMeter sendID3:extraString];
                }
            }
        }
    }
}


# pragma mark -
# pragma mark Nielsen App API Delegates
# pragma mark -

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event {
    NSLog(@"Sample player is Notified by an Event : %@", event);
}

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error {
    NSLog(@"Sample player is Notified by an Error : %@", error);
}

@end
