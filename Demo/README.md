# Nielsen App API SDK

This document will guide you through implementing the Nielsen App API SDK.  Read the engineering forum for more details and documentation.


## Implementing the SDK


### Configure the Nielsen App SDK


#### Frameworks

Add the following to Linked Frameworks and Libraries:

* CoreMedia
* AVFoundation
* Security
* SystemConfiguration
* AdSupport
* Foundation
* UIKit
* CoreLocation
* libsqlite3.dylib
* NielsenAppApi


#### Build Settings

Navigate to Build Settings > Linking > Other Linker Flags and add lstdc++ for Any Architecture | Any SDK.


### Instantiate the SDK

    NSDictionary *nielsenConfig = @{
        @"appid": @"T6DABF79D-CE15-4A47-A201-4E7DFE0F7EF0",
        @"appversion": @"1.0",
        @"appname": @"SDK Demo",
        @"sfcode": @"uat"
    };
    NSData *jsonDataNielsenConfig = [NSJSONSerialization dataWithJSONObject:nielsenConfig options:0 error:nil];
    NSString *jsonStringNielsenConfig = [[NSString alloc] initWithBytes:[jsonDataNielsenConfig bytes] length:[jsonDataNielsenConfig length] encoding:NSUTF8StringEncoding];
    nielsenMeter = [[NielsenAppApi alloc] initWithAppInfo:jsonStringNielsenConfig delegate:self];


### Configure the player

    NSDictionary *playerInfoDict = @{
        @"channelName": @"Video Demo",
        @"adModel": @"2",
        @"dataSrc": @"id3"
    };
    NSData *playerInfoData = [NSJSONSerialization dataWithJSONObject:playerInfoDict options:0 error:nil];
    playerInfo = [[NSString alloc] initWithBytes:[playerInfoData bytes] length:[playerInfoData length] encoding:NSUTF8StringEncoding];


### Configure the asset

    hString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    NSDictionary *assetInfoDict = @{
        @"type": @"content",
        @"assetid": @"demo",
        @"tv": @"true",
        @"program": @"Demo Program",
        @"title": @"Demo Episode",
        @"category": @"test",
        @"adModel": @"2",
        @"dataSrc": @"id3"
    };
    NSData *assetInfoData = [NSJSONSerialization dataWithJSONObject:assetInfoDict options:0 error:nil];
    assetInfo = [[NSString alloc] initWithBytes:[assetInfoData bytes] length:[assetInfoData length] encoding:NSUTF8StringEncoding];


### Register Key Value Observers on status and rate.  Register currentItem.timedMetadata if using ID3

    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"currentItem.timedMetadata" options:0 context:nil];


### Observe player every 2 seconds and update playheadPosition

    CMTime i = CMTimeMakeWithSeconds(2.0, NSEC_PER_SEC);
    [self.avPlayerViewcontroller.player addPeriodicTimeObserverForInterval:i queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSLog(@"Update playhead position");
        CMTime t = [self.avPlayerViewcontroller.player currentTime];
        long position = CMTimeGetSeconds(t);
        [nielsenMeter playheadPosition:position];
    }];


### Watch for rate changes to handle pauses in playback.  A rate of 0 is paused.


### Watch status to play asset once loaded


### Parse ID3 Tags and send to Nielsen App API


### Implement Nielsen App API Delegate

