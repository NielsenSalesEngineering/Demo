//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import "ID3VideoViewController.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "NielsenAppApi/NielsenAppApi.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


NielsenAppApi *nielsenMeter = nil;
NSArray* array;
NSString *playerInfo;


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
                                 @"dataSrc": @"id3"
                                 };
    NSData *playerInfoData = [NSJSONSerialization dataWithJSONObject:playerInfoDict options:0 error:nil];
    playerInfo = [[NSString alloc] initWithBytes:[playerInfoData bytes] length:[playerInfoData length] encoding:NSUTF8StringEncoding];
    
    // Configure the asset
    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    NSDictionary *assetInfoDict = @{
                                @"type": @"content",
                                @"assetid": @"",
                                @"tv": @"true",
                                @"program": @"MyProgram",
                                @"title": @"MyEpisodeTitle",
                                @"category": @"testcat",
                                @"adModel": @"2",
                                @"dataSrc": @"id3"
                                };
    NSData *assetInfoData = [NSJSONSerialization dataWithJSONObject:assetInfoDict options:0 error:nil];
    NSString *assetInfo = [[NSString alloc] initWithBytes:[assetInfoData bytes] length:[assetInfoData length] encoding:NSUTF8StringEncoding];
    [nielsenMeter loadMetadata:assetInfo];

    // Configure an AVPlayerViewController
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:url];
    self.avPlayerViewcontroller = playerViewController;
    [self resizePlayerToViewSize];
    [self.view addSubview:playerViewController.view];
    self.view.autoresizesSubviews = TRUE;
    
    // Register Key Value Observers on status and rate attributes
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    // Observe player every 2 seconds and update playheadPosition
    CMTime i = CMTimeMakeWithSeconds(2.0, NSEC_PER_SEC);
    [self.avPlayerViewcontroller.player addPeriodicTimeObserverForInterval:i queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSLog(@"Update playhead position");
        CMTime t = [self.avPlayerViewcontroller.player currentTime];
        long position = CMTimeGetSeconds(t);
        [nielsenMeter playheadPosition:position];
    }];
}

- (void) resizePlayerToViewSize {
    CGRect frame = self.view.frame;
    NSLog(@"frame size %d, %d", (int)frame.size.width, (int)frame.size.height);
    self.avPlayerViewcontroller.view.frame = frame;
}

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    // Watch for rate changes to handle pauses in playback.  A rate of 0 is paused.
    if ([path isEqualToString:@"rate"]) {
        if ([self.avPlayerViewcontroller.player rate]) {
            NSLog(@"Unpaused.");
            [nielsenMeter play:playerInfo];
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
        NSLog(@"Timed metadata.");
        array =[[player currentItem] timedMetadata];
        for (AVMetadataItem *metadataItem in array) {
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
                    // Send ID3 Tag
                    [nielsenMeter sendID3:extraString];
                    NSString *value = [metadataItem stringValue];
                    if (value != nil) {
                        NSLog(extraString);
                    }
                }
            } else {
                NSLog(@"Could not send ID3 Tags");
            }
        }
    }
}

-(void)notifyInActive:(NSNotification *)notification {
    NSLog(@"notifyInActive: %@", notification.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


# pragma mark -
# pragma mark Nielsen App API Delegates
# pragma mark -

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event {
    NSLog(@"Sample player is Notified by a Event : %@", event);
}

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error {
    NSLog(@"Sample player is Notified by an Error : %@", error);
}

@end
