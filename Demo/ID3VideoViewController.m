//
//  ID3VideoViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "ID3VideoViewController.h"
#import "PlayerView.h"

@interface ID3VideoViewController ()

@end

@implementation ID3VideoViewController
@synthesize player, playerView, playerItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://nielsense-assets.s3.amazonaws.com/id3/001/prog_index.m3u8"];
    player = [AVPlayer playerWithURL:url];
    
    [self.playerView setPlayer:player];
    [player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
