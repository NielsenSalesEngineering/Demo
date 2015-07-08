//
//  ID3VideoViewController.h
//  Demo
//
//  Created by Wesley Kincaid on 4/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <NielsenAppApi/NielsenAppApi.h>
@import WebKit;

@class PlayerView;
@interface ID3VideoViewController : UIViewController <NielsenAppApiDelegate, WKNavigationDelegate>

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic, weak) PlayerView *playerView;
@end

