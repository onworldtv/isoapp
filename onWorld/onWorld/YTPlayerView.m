//
//  YTPlayerView.m
//  OnWorld
//
//  Created by yestech1 on 7/9/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTPlayerView.h"

@implementation YTPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)[self layer];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (NSString *)getVideoFillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    return playerLayer.videoGravity;
}

@end
