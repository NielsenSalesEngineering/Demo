//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 4/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

# pragma mark Standard View Controller Stuff

#import "ID3VideoViewController.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "NielsenAppApi/NielsenAppApi.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@import UIKit;
@import WebKit;


NielsenAppApi *nielsenMeter = nil;
NSString *playerInfo;
NSString *assetInfo;
WKWebView *webView;


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
    
    // Provide a button to opt out
    NSString *labelText = @"Opt Out";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12]};
    CGSize size = [labelText sizeWithAttributes:attributes];
    button.frame = CGRectMake(5, 55, size.width + 20, size.height);
    [button setTitle:labelText forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didSelectOptOut) forControlEvents:UIControlEventTouchUpInside];
    [button setUserInteractionEnabled:YES];
    [button setEnabled:YES];
    [self.avPlayerViewcontroller.view addSubview:button];
    
    // Register Key Value Observers on status and rate.  Register currentItem.timedMetadata if using ID3
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    // Observe player every 2 seconds and update playheadPosition
    CMTime i = CMTimeMakeWithSeconds(2.0, NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    [self.avPlayerViewcontroller.player addPeriodicTimeObserverForInterval:i queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CMTime t = [weakSelf.avPlayerViewcontroller.player currentTime];
        long position = CMTimeGetSeconds(t);
        [nielsenMeter playheadPosition:position];
    }];
}

- (void)notifyInActive:(NSNotification *)notification {
    NSLog(@"notifyInActive: %@", notification.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


# pragma mark -
# pragma mark Key Value Observation

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // Watch for rate changes to handle pauses in playback.  A rate of 0 is paused.
    if ([path isEqualToString:@"rate"]) {
        if ([self.avPlayerViewcontroller.player rate]) {
            [nielsenMeter play:playerInfo];
            [nielsenMeter loadMetadata:assetInfo];
        } else {
            [nielsenMeter stop];
        }
        
    // Watch status to play asset once loaded
    } else if ([path isEqualToString:@"status"]) {
        if (self.avPlayerViewcontroller.player.status == AVPlayerItemStatusReadyToPlay) {
            [self.avPlayerViewcontroller.player play];
            [nielsenMeter play:playerInfo];
        }
    }
}


# pragma mark -
# pragma mark Privacy Opt Out

- (void)didSelectOptOut {
    
    // Load optOutURLString into a Web View for opt out
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    webView.navigationDelegate = self;
    NSURL *url = [NSURL URLWithString:[nielsenMeter optOutURLString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    NSString *labelButtonText = @"Close";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12]};
    CGSize size = [labelButtonText sizeWithAttributes:attributes];
    button.frame = CGRectMake(5, 55, size.width + 20, size.height);
    [button setTitle:labelButtonText forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeOptOutView) forControlEvents:UIControlEventTouchUpInside];
    [button setUserInteractionEnabled:YES];
    [button setEnabled:YES];
    [webView addSubview:button];
    [self.view addSubview:webView];
}

- (void)closeOptOutView {
    
    // Pass URL from Web View to userOptOut to enable/disable tracking
    NSString *finalURL = [NSString stringWithFormat:@"%@", webView.URL];
    [nielsenMeter userOptOut:finalURL];
    [webView removeFromSuperview];
}


# pragma mark -
# pragma mark Nielsen App API Delegates

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event {
    NSLog(@"Sample player is Notified by an Event : %@", event);
}

// Fulfill Nielsen App API Delegate
- (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error {
    NSLog(@"Sample player is Notified by an Error : %@", error);
}

@end
