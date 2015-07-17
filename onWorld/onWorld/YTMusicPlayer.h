//
//  YTMusicPlayer.h
//  OnWorld
//
//  Created by yestech1 on 7/17/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface YTMusicPlayer : NSObject

@property(nonatomic,strong) AVPlayer *avQueuePlayer;

+ (void)sharedSession;

- (void)playWithUrlPath:(NSString *)urlPath songTitle:(NSString*)songTitle singerName:(NSString*)singerName;

- (void)pause;

- (void)play;

- (void)clear;

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;
@end
