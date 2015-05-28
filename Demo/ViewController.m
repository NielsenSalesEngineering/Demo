//
//  ViewController.m
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import "ViewController.h"
#import "PlayerView.h"

@interface ViewController ()

@end

@implementation ViewController
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
