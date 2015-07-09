//
//  YTPlayerView.h
//  OnWorld
//
//  Created by yestech1 on 7/9/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;
- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (NSString *)getVideoFillMode;
- (AVPlayerLayer *)playerLayer;

@end
