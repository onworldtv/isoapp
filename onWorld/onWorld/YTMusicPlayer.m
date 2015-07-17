//
//  YTMusicPlayer.m
//  OnWorld
//
//  Created by yestech1 on 7/17/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTMusicPlayer.h"

@implementation YTMusicPlayer


+ (void)sharedSession {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    //set audio category with options - for this demo we'll do playback only
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&categoryError];
    
    if (categoryError) {
        NSLog(@"Error setting category! %@", [categoryError description]);
    }
    
    //activation of audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
        } else {
            NSLog(@"audio session could not be activated!");
        }
    }
    
}

- (AVPlayer *)avQueuePlayer {
    if (!_avQueuePlayer) {
        _avQueuePlayer = [[AVQueuePlayer alloc]init];
    }
    
    return _avQueuePlayer;
}

- (void)playWithUrlPath:(NSString *)urlPath songTitle:(NSString*)songTitle singerName:(NSString*)singerName {
    
    if (urlPath) {
        NSURL *assetUrl = [NSURL URLWithString:urlPath];
        AVPlayerItem *avSongItem = [[AVPlayerItem alloc] initWithURL:assetUrl];
        if (avSongItem) {
//            [[self avQueuePlayer] insertItem:avSongItem afterItem:nil];
            self.avQueuePlayer = [[AVPlayer alloc]initWithPlayerItem:avSongItem];
            [self play];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: singerName};
        }
    }
}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [self.avQueuePlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}


#pragma mark - notifications
- (void)audioSessionInterrupted:(NSNotification*)interruptionNotification {
    NSLog(@"interruption received: %@", interruptionNotification);
}

#pragma mark - player actions
- (void)pause {
    [[self avQueuePlayer] pause];
}

- (void)play {
    [[self avQueuePlayer] play];
}


- (void)clear {
//    [[self avQueuePlayer] removeAllItems];
    [self.avQueuePlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:nil];
}

#pragma mark - remote control events

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    NSLog(@"received event!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if ([self avQueuePlayer].rate > 0.0) {
                    [[self avQueuePlayer] pause];
                } else {
                    [[self avQueuePlayer] play];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [[self avQueuePlayer] play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [[self avQueuePlayer] pause];
                break;
            }
            default:
                break;
        }
    }
}

@end
