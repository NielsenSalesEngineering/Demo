//
//  ID3VideoViewController.h
//  Demo
//
//  Created by Wesley Kincaid on 5/26/15.
//  Copyright (c) 2015 Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <NielsenAppApi/NielsenAppApi.h>

@class PlayerView;
@interface ID3VideoViewController : UIViewController <NielsenAppApiDelegate>

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic, weak) IBOutlet PlayerView *playerView;
@end

