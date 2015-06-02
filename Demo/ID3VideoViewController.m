//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "NielsenAppApi/NielsenAppApi.h"
#import "ID3VideoViewController.h"
#import "PlayerView.h"

@interface ID3VideoViewController ()

@end

@implementation ID3VideoViewController

@synthesize player, playerView, playerItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the Nielsen App SDK
    // Config must be translated to JSON
    NSDictionary *nielsenConfig = @{
                                    @"appid": @"TOKFGHT7382-F4A9-4ERG1-9C00-7XXXXXC6",
                                    @"appversion": @"1.0",
                                    @"appname": @"SDK Demo",
                                    @"sf-code": @"cert"
                                    };
    NSData *jsonDataNielsenConfig = [NSJSONSerialization dataWithJSONObject:nielsenConfig options:0 error:nil];
    NSString *jsonStringNielsenConfig = [[NSString alloc] initWithBytes:[jsonDataNielsenConfig bytes] length:[jsonDataNielsenConfig length] encoding:NSUTF8StringEncoding];
    NielsenAppApi *nielsenMeter = [[NielsenAppApi alloc] initWithAppInfo:jsonStringNielsenConfig delegate:self];
    
    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    player = [AVPlayer playerWithURL:url];
    
    [self.playerView setPlayer:player];
    [player play];
}

# pragma mark -
# pragma mark Nielsen App API Delegates
# pragma mark - 

- (void)nielsenAppApi:(NielsenAppApi *)appApi eventOccurred:(NSDictionary *)event
{
    NSLog(@"Sample player is Notified by a Event : %@", event);
}

- (void)nielsenAppApi:(NielsenAppApi *)appApi errorOccurred:(NSDictionary *)error
{
    NSLog(@"Sample player is Notified by an Error : %@", error);
}

-(void)notifyInActive:(NSNotification *)notification{
    NSLog(@"Sample player is Notified by a Event : %@",notification.userInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
