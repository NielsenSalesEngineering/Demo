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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSURL *content_with_captions = [NSURL URLWithString:@"http://content.uplynk.com/209da4fef4b442f6b8a100d71a9f6a9a.m3u8"];
    player = [AVPlayer playerWithURL:content_with_captions];
    
    [self.playerView setPlayer:player];
    [player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
