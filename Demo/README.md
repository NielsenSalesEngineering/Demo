# Nielsen App API SDK Implementation

This document will guide you through implementing the Nielsen App API SDK.  Read Nielsen's [Engineering Client Portal](http://engineeringforum.nielsen.com/sdk/developers/) for more details and documentation.


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

`[NielsenAppApi initWithAppInfo:delegate:]` expects a `JSON` formatted string, which we construct from a dictionary below.  Delegate methods are documented later in this tutorial.

    NSDictionary *nielsenConfig = @{
        @"appid": @"T6DABF79D-CE15-4A47-A201-4E7DFE0F7EF0",
        @"appversion": @"1.0",
        @"appname": @"SDK Demo",
        @"sfcode": @"uat"
    };
    NSData *jsonDataNielsenConfig = [NSJSONSerialization dataWithJSONObject:nielsenConfig options:0 error:nil];
    NSString *jsonStringNielsenConfig = [[NSString alloc] initWithBytes:[jsonDataNielsenConfig bytes] length:[jsonDataNielsenConfig length] encoding:NSUTF8StringEncoding];
    nielsenMeter = [[NielsenAppApi alloc] initWithAppInfo:jsonStringNielsenConfig delegate:self];


### Player Configuration

`[NielsenAppApi play:]` expects a `JSON` formatted string, which we construct from a dictionary below.

    NSDictionary *playerInfoDict = @{
        @"channelName": @"Video Demo",
        @"adModel": @"2",
        @"dataSrc": @"id3"
    };
    NSData *playerInfoData = [NSJSONSerialization dataWithJSONObject:playerInfoDict options:0 error:nil];
    playerInfo = [[NSString alloc] initWithBytes:[playerInfoData bytes] length:[playerInfoData length] encoding:NSUTF8StringEncoding];


### Asset Metadata Configuration

`[NielsenAppApi loadMetadata:]` expects a `JSON` formatted string, which we construct from a dictionary below.

    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
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


### Implement KVO

Register key-value observers on the player's `status` and `rate` keys.  If you're using ID3 encoded media, register `currentItem.timedMetadata`.

Read Apple's [Introduction to Key-Value Observing Programming Guide](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html) for an overview of KVO.

    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"currentItem.timedMetadata" options:0 context:nil];


### Updating Playhead Position 

Observe player every 2 seconds and update `[NielsenAppApi playheadPosition:]`.

    CMTime i = CMTimeMakeWithSeconds(2.0, NSEC_PER_SEC);
    [self.avPlayerViewcontroller.player addPeriodicTimeObserverForInterval:i queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSLog(@"Update playhead position");
        CMTime t = [self.avPlayerViewcontroller.player currentTime];
        long position = CMTimeGetSeconds(t);
        [nielsenMeter playheadPosition:position];
    }];


### Observing Play and Pause Events

Watch the playback rate for changes to handle pauses.  A rate of 0 is paused.  1 is normal playback.

    if ([path isEqualToString:@"rate"]) {
        if ([self.avPlayerViewcontroller.player rate]) {
            NSLog(@"Unpaused.");
            [nielsenMeter play:playerInfo];
            [nielsenMeter loadMetadata:assetInfo];
        } else {
            NSLog(@"Paused.");
            [nielsenMeter stop];
        }


### Play Asset

Observe `status` key to play asset once loaded.

    } else if ([path isEqualToString:@"status"]) {
        if (self.avPlayerViewcontroller.player.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"Ready to play");
            [self.avPlayerViewcontroller.player play];
            [nielsenMeter play:playerInfo];
        }


### ID3 Metadata

Observe `currentItem.timedMetadata` and parse ID3 data when fired.

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


### Implement Delegate Methods

Implement `[NielsenAppApi eventOccurred:]` and `[NielsenAppApi errorOccurred:]` in order to fulfill the Nielsen App API delegate.  Don't forget to add `<NielsenAppApiDelegate>` to your view controller's `@interface`.

    - (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event {
        NSLog(@"Sample player is Notified by a Event : %@", event);
    }

    - (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error {
        NSLog(@"Sample player is Notified by an Error : %@", error);
    }


## Getting Help

Reach out to SalesEngineeringGlobal@nielsen.com or visit Nielsen's [Engineering Client Portal](http://engineeringforum.nielsen.com/sdk/developers/) for more information.

