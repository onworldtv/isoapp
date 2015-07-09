//
//  YTPlayerViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTPlayerViewController.h"

/* Asset keys */
NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey       = @"playable";
NSString * const kYTDuration        = @"duration";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";
NSString * const kPlaybackBufferEmpty = @"playbackBufferEmpty";

/* AVPlayer keys */
NSString * const kRateKey           = @"rate";
NSString * const kCurrentItemKey    = @"currentItem";
NSString * const kAirplayKey		= @"externalPlaybackActive";



static void *YTPlayerViewControllerRateObserverContext = &YTPlayerViewControllerRateObserverContext;
static void *YTPlayerViewControllerStatusObservationContext = &YTPlayerViewControllerStatusObservationContext;
static void *YTPlayerViewControllerCurrentItemObserverContext = &YTPlayerViewControllerCurrentItemObserverContext;

@interface YTPlayerViewController ()
{
    BOOL seekToZeroBeforePlay;
    
    AVPlayer* mPlayer;
    AVPlayerItem* mPlayerItem;
}
@end

@implementation YTPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initScrubberTimer];
    [self setUpGesture];
    [self initSystemVolumn];
    [self animationHiddenView];
}


- (void)setUpGesture {
    UITapGestureRecognizer *playerViewTap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
    [playerViewTap setNumberOfTapsRequired:1];
    playerViewTap.delegate = self;
    [self.playerView addGestureRecognizer:playerViewTap];
    
    UITapGestureRecognizer *rightViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
    [rightViewTap setNumberOfTapsRequired:1];
    rightViewTap.delegate = self;
    [self.playerView addGestureRecognizer:rightViewTap];
    
    [self.timelineView addGestureRecognizer:rightViewTap];
    
    UITapGestureRecognizer *doubleTapGuestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerDoubleTapped:)];
    [doubleTapGuestureRecognizer setNumberOfTapsRequired:2];
    doubleTapGuestureRecognizer.delegate = self;
    [self.playerView addGestureRecognizer:doubleTapGuestureRecognizer];
    [playerViewTap requireGestureRecognizerToFail:doubleTapGuestureRecognizer];
}

- (void)initSystemVolumn {
   
    _volumnView.showsVolumeSlider = YES;
    _volumnView.showsRouteButton = NO;
    for (UIView *vw in _volumnView.subviews) {
        if ([vw isKindOfClass:[UISlider class]]) {
            [((UISlider*)vw) setMinimumValueImage:[UIImage imageNamed:@"music_mute_white_iphone"]];
            [((UISlider*)vw) setMaximumValueImage:[UIImage imageNamed:@"music_sound_white_iphone"]];
        }
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)setUrlPath:(NSURL*)URL{
    if (_urlPath != URL)
    {
        _urlPath = [URL copy];
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_urlPath options:nil];
        
        NSArray *requestedKeys = @[kPlayableKey];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];
    }
}


- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *error = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:error];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (mPlayerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [mPlayerItem removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:mPlayerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [mPlayerItem addObserver:self
                       forKeyPath:kStatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:YTPlayerViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:mPlayerItem];
    
//    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!mPlayer)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        mPlayer = [AVPlayer playerWithPlayerItem:mPlayerItem];
//        [self setPlayer:[AVPlayer playerWithPlayerItem:mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [mPlayer addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:YTPlayerViewControllerCurrentItemObserverContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [mPlayer addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:YTPlayerViewControllerRateObserverContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (mPlayer.currentItem != mPlayerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [mPlayer replaceCurrentItemWithPlayerItem:mPlayerItem];
        
        [self syncPlayPauseButtons];
    }
    [self.sliderTrackView setValue:0.0];
}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context{
    /* AVPlayerItem "status" property value observer. */
    if (context == YTPlayerViewControllerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatusUnknown");
//                [self removePlayerTimeObserver];
//                [self syncScrubber];
//                
//                [self disableScrubber];
//                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                
                [mPlayer play];
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
//                [self initScrubberTimer];
//                
//                [self enableScrubber];
//                [self enablePlayerButtons];
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"AVPlayerItemStatusFailed");
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == YTPlayerViewControllerRateObserverContext)
    {
        NSLog(@"AVPlayerDemoPlaybackViewControllerRateObservationContext");
        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == YTPlayerViewControllerCurrentItemObserverContext)
    {
        NSLog(@"AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext");
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
//            [self disablePlayerButtons];
//            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.playerView setPlayer:mPlayer];
//
//            [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
    else
    {
        NSLog(@"AVPlayerItemStatusFailed =============");
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

- (void)syncPlayPauseButtons{
    if ([self isPlaying])
    {
        [self showStopButton];
    }
    else
    {
        [self showPlayButton];
    }
}


- (BOOL)isPlaying {
    if(mPlayer.rate > 0 && mPlayer.error == nil)
        return YES;
    return NO;
}

-(void)initScrubberTimer{
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.sliderTrackView bounds]);
        interval = 0.5f * duration / width;
    }
    
    /* Update the scrubber during normal playback. */
    __weak YTPlayerViewController *weakSelf = self;
//    mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
//                                                               queue:NULL /* If you pass NULL, the main queue is used. */
//                                                          usingBlock:^(CMTime time)
//                     {
//                         [weakSelf syncScrubber];
//                     }];
}

- (void)syncScrubber{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _sliderTrackView.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.sliderTrackView minimumValue];
        float maxValue = [self.sliderTrackView maximumValue];
        double time = CMTimeGetSeconds([mPlayer currentTime]);
        
        [self.sliderTrackView setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    /* After the movie has played to its end time, seek back to time zero
     to play it again.*/
    seekToZeroBeforePlay = YES;
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error {
    
    [self syncScrubber];
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}





-(void)showStopButton{
    [_btnPlay setImage:[UIImage imageNamed:@"icon_player"] forState:UIControlStateNormal];
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton{
    [_btnPlay setImage:[UIImage imageNamed:@"icon_player"] forState:UIControlStateNormal];
}



#pragma mark - gesture


- (void)playerTapped:(UITapGestureRecognizer *)sender {
    if(_topView.isHidden) {
        [self animationAppearView];
    }else {
        [self animationHiddenView];
    }
}

- (void)playerDoubleTapped:(UITapGestureRecognizer *)sender {
    
    if ([[self.playerView getVideoFillMode] isEqualToString:AVLayerVideoGravityResizeAspectFill])
        [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    else{
        [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
        [self animationHiddenView];
    }
}

- (IBAction)click_closePlayer:(id)sender {
#warning todo;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)releasePlayer {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:nil];
    if(mPlayerItem) {
        [mPlayerItem removeObserver:self forKeyPath:kStatusKey];
        [mPlayerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
        [mPlayerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    }
    if(mPlayer) {
        [mPlayer removeObserver:self forKeyPath:kRateKey];
        [mPlayer removeObserver:self forKeyPath:kCurrentItemKey];
        [mPlayer removeObserver:self forKeyPath:kAirplayKey];
    }
    /*
     NSString * const kTracksKey         = @"tracks";
     NSString * const kPlayableKey       = @"playable";
     NSString * const kYTDuration        = @"duration";*/
     
   
    
    }

- (IBAction)click_cast:(id)sender {
    
}


- (void)animationHiddenView {
    
    [UIView animateWithDuration:1 animations:^{
        [_topView setAlpha:0];
        [_topView setHidden:YES];
        [_bottomView setAlpha:0];
        [_bottomView setHidden:YES];
        [_timelineView setAlpha:0];
        [_timelineView setHidden:YES];
    }];
}

- (void)animationAppearView {
    
    [UIView animateWithDuration:1 animations:^{
        [_topView setAlpha:1];
        [_timelineView setAlpha:1];
        [_bottomView setAlpha:1];
        [_topView setHidden:NO];
        [_bottomView setHidden:NO];
        [_timelineView setHidden:NO];
    }];
}

- (IBAction)click_playlist:(id)sender {
    
}

- (IBAction)click_play:(id)sender {
    
    if([self isPlaying]) {
        [mPlayer pause];
    }else {
        if (YES == seekToZeroBeforePlay)
        {
            seekToZeroBeforePlay = NO;
            [mPlayer seekToTime:kCMTimeZero];
        }
        [mPlayer play];
        
        [self showStopButton];
    }
}
@end
