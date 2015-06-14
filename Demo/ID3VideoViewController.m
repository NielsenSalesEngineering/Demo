//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "NielsenAppApi/NielsenAppApi.h"
#import "ID3VideoViewController.h"
#import "PlayerView.h"

//static void *MyStreamingMovieViewControllerTimedMetadataObserverContext = &MyStreamingMovieViewControllerTimedMetadataObserverContext;
//static void *MyStreamingMovieViewControllerRateObservationContext = &MyStreamingMovieViewControllerRateObservationContext;
//static void *MyStreamingMovieViewControllerCurrentItemObservationContext = &MyStreamingMovieViewControllerCurrentItemObservationContext;
//static void *MyStreamingMovieViewControllerPlayerItemStatusObserverContext = &MyStreamingMovieViewControllerPlayerItemStatusObserverContext;

NielsenAppApi *nielsenMeter = nil;
NSArray* array;
NSTimer *playheadTimer;

@interface ID3VideoViewController ()

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
    
    // Configure a play head timer
    //playheadTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(playHeadTimeEvent) userInfo:nil repeats:YES];
    
    // Configure the player
    NSDictionary *playerInfoDict = @{
                                 @"channelName": @"Video Demo",
                                 @"adModel": @"2",
                                 @"dataSrc": @"id3"
                                 };
    NSData *playerInfoData = [NSJSONSerialization dataWithJSONObject:playerInfoDict options:0 error:nil];
    NSString *playerInfo = [[NSString alloc] initWithBytes:[playerInfoData bytes] length:[playerInfoData length] encoding:NSUTF8StringEncoding];
    [nielsenMeter play:playerInfo];
    
    // Configure the asset
    NSDictionary *assetInfoDict = @{
                                @"type": @"content",
                                @"assetid": @"assetid",
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
    
    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    player = [AVPlayer playerWithURL:url];
    
    [self.playerView setPlayer:player];
    [player play];
}

//-(void)playHeadTimeEvent {
//    CMTime currentTime = [player currentTime];
//    int position = CMTimeGetSeconds(currentTime);
//    [nielsenMeter playheadPosition:position];
//}
//
//-(void)handleTimedMetada:(AVMetadataItem*)timedMetadata {
//    id extraAttributeType = [timedMetadata extraAttributes];
//    NSString *extraString = nil;
//    if ([extraAttributeType isKindOfClass:[NSDictionary class]]) {
//        extraString = [extraAttributeType valueForKey:@"info"];
//    }
//    else if ([extraAttributeType isKindOfClass:[NSString class]]) {
//        extraString = extraAttributeType;
//    }
//    
//    if ([(NSString *)[timedMetadata key] isEqualToString:@"PRIV"] && [extraString rangeOfString:@"www.nielsen.com"].length > 0) {
//        if ([[timedMetadata value] isKindOfClass:[NSData class]]) {
//            // Send ID3 Tag
//            [nielsenMeter sendID3:extraString];
//            NSString *value = [timedMetadata stringValue];
//            if (value != nil) {
//                NSLog(extraString);
//            }
//        }
//    } else {
//        NSLog(@"Could not send ID3 Tags");
//    }
//};


//- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    NSLog(@"Observed value");
//    @try {
//        if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext) {
//            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//            switch (status) {
//                case AVPlayerStatusReadyToPlay:
//                    break;
//                case AVPlayerStatusFailed:
//                    break;
//                case AVPlayerStatusUnknown:
//                    break;
//            }
//        } else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext) {
//            NSLog(@"MyStreamingMovieViewControllerCurrentItemObservationContext");
//        } else if (context == MyStreamingMovieViewControllerTimedMetadataObserverContext) {
//            array = [[player currentItem] timedMetadata];
//            for (AVMetadataItem *metadataItem in array) {
//                [self handleTimedMetada:metadataItem];
//            }
//        } else {
//            if (context && object) {
//                [self observeValueForKeyPath:path ofObject:object change:change context:context];
//            }
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"catching %@ reason %@", [exception name], [exception reason]);
//    }
//}
//
//-(void)notifyInActive:(NSNotification *)notification {
//    NSLog(@"Sample player is Notified by a Event : %@",notification.userInfo);
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}


# pragma mark -
# pragma mark Nielsen App API Delegates
# pragma mark -

- (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event {
    NSLog(@"Sample player is Notified by a Event : %@", event);
}

- (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error {
    NSLog(@"Sample player is Notified by an Error : %@", error);
}

@end
