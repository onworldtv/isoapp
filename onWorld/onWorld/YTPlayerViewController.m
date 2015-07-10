//
//  YTPlayerViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTPlayerViewController.h"
#import "YTTimelineViewCell.h"

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

static void *YTPlayerAdPlayerItemStatusObservationContext = &YTPlayerAdPlayerItemStatusObservationContext;

@interface YTPlayerViewController ()
{
    BOOL seekToZeroBeforePlay;
    AVPlayer* mPlayer;
    AVPlayerItem* mPlayerItem;
    
    YTAdv *currentAdv;
    AVPlayerItem *playerItemAdv;
    AVPlayer *playerAdv;
    YTContent * contentObj;
    YTDetail * detail;
    BOOL isSwipeRight;
    int contentID;
    
    id mTimeObserver;
    NSString *linkPlay;

}
@end

@implementation YTPlayerViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil itemID:(int)ID {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        contentID = ID;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initScrubberTimer];
    [self setUpGesture];
    [self initSystemVolumn];
    [self animationHiddenView];
    [self playerAdv];
    
    [_tbvTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tbvTableView setHidden:YES];
    [_tbvTableView setAlpha:0];
}


- (void)initViewToPrepareBeginPlay {
    if(detail.isLive) {
        // hiden slider tracking
        [self.sliderTrackView setEnabled:NO];
        [self.sliderTrackView setHidden:YES];
        [self.txtDurated setHidden:YES];
        [self.txtDuration setHidden:YES];
    }else { // display isLive

    }
    
    if(detail.episode.allObjects.count == 0) {
        [self.btnPlayList setEnabled:NO];
    }
}

- (void)loadDataForPlayer {
    
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID)];
    BFTask *task = nil;
    if(contentObj.detail) {
        task = [BFTask taskWithResult:nil];
    }else {
        task = [DATA_MANAGER pullAndSaveContentDetail:contentID];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            if(contentObj == nil) {
                contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID)];
                detail = contentObj.detail;
                [_txtTitle setText:contentObj.name];
            }
        }else {
#warning TODO
        }
        return nil;
    }];
}



#pragma mark - player


- (void)playerAdv {
    
//    if(!contentObj.detail) {
//#warning TODO
//        return ;
//    }
    NSArray *advs = [contentObj.detail.adv allObjects];
    for(YTAdv *adv in advs) {
        if(adv.type.intValue == TypeVideo) {
            currentAdv =  adv;
        }
    }
    
    NSURL *advUrl = [NSURL URLWithString:currentAdv.link];
    NSURL *url = [NSURL URLWithString:@"http://tracker.onworldtv.com/www/delivery/fc.php?script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml&nz=1&format=vast&zones=overlay:0.0-0%3D19"];
    
    AVPlayerItem *adPlayerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoAdvPlayerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:adPlayerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoAdPlayerItemFailedToReachEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:adPlayerItem];
    
    [adPlayerItem addObserver:self forKeyPath:kStatusKey
                      options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                      context:YTPlayerAdPlayerItemStatusObservationContext];
    
    
    
    playerItemAdv = adPlayerItem;
    
    playerAdv = [[AVPlayer alloc]initWithPlayerItem:playerItemAdv];
    
    
    // update duration & current time
    __weak YTPlayerViewController * weakSelf = self;
    [playerAdv addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {

        int i = (int)(currentAdv.duration.intValue - CMTimeGetSeconds(playerAdv.currentTime));
        if (i >= 0) {
            NSString *lbAdvSecond = [NSString stringWithFormat:@"This ad will close in %d", i];
            [weakSelf.lbAdvSecondTime setText:lbAdvSecond];
        }
        else {
            [weakSelf.lbAdvSecondTime setText:@""];

        }
    }];
    [mPlayer pause];
    [playerAdv play];
    
}





- (void)startPlayer {
    [self.loadingView setHidden:NO];
    [self.loadingView startAnimating];
    if (linkPlay == nil)
    {
        
         NSURL *ulrPath = [NSURL URLWithString:@"http://origin.onworldtv.com:1935/liveorigin/stream_lstv/playlist.m3u8?worldtokenstarttime=1436411142&worldtokenendtime=1436495742&worldtokenhash=OceWL9xxvx_vjoca1ju-njEW6FjyqxbqToo8TI4gSWY="];
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:ulrPath options:nil];
        
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

- (void)setUpGesture {
    UITapGestureRecognizer *playerViewTap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
    [playerViewTap setNumberOfTapsRequired:1];
    playerViewTap.delegate = self;
    [self.playerView addGestureRecognizer:playerViewTap];
    
    
    UITapGestureRecognizer *doubleTapGuestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerDoubleTapped:)];
    [doubleTapGuestureRecognizer setNumberOfTapsRequired:2];
    doubleTapGuestureRecognizer.delegate = self;
    [self.playerView addGestureRecognizer:doubleTapGuestureRecognizer];
    [playerViewTap requireGestureRecognizerToFail:doubleTapGuestureRecognizer];
    
    
    
    
    //timeline
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(timelineViewSwipeLeft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.tbvTableView addGestureRecognizer:swipeleft];
    
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(timelineViewSwipeRight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.tbvTableView addGestureRecognizer:swiperight];
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
                [self.loadingView stopAnimating];
                [self.loadingView setHidden:YES];
                [mPlayer play];
                
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
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
        
        
    }else if(context == YTPlayerAdPlayerItemStatusObservationContext) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                [self.playerView setPlayer:playerAdv];
            }
            break;
                
            case AVPlayerItemStatusFailed:
            {
                [self didFinishAdvPlayer];
            }
                break;
        }
    }else
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
    if(detail.isLive.intValue == 0) {
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
        //    mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
        //                                                               queue:NULL /* If you pass NULL, the main queue is used. */
        //                                                          usingBlock:^(CMTime time)
        //                     {
        //                         [weakSelf syncScrubber];
        //                     }];
        
        mTimeObserver = [mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                              queue:NULL /* If you pass NULL, the main queue is used. */
                                                         usingBlock:^(CMTime time){
                                                             [weakSelf syncScrubber];
                                                         }];
    }
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

-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
    {
        [mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
    }
}

#pragma mark - notification  player Item

- (void)videoAdvPlayerItemDidReachEnd:(NSNotification *)notification {
    [self didFinishAdvPlayer];
}


- (void)playerItemDidReachEnd:(NSNotification *)notification{
    /* After the movie has played to its end time, seek back to time zero
     to play it again.*/
    seekToZeroBeforePlay = YES;
}




- (void)didFinishAdvPlayer {
    
    [self.topViewAdv setHidden:YES];
    // begin player
    if(mPlayer) {
        [mPlayer play];
    }else {
        [self startPlayer];
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error {
    
    [self.loadingView stopAnimating];
    [self.loadingView setHidden:YES];
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


-(void)timelineViewSwipeLeft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    
    CGRect tblFrame = self.tbvTableView.frame;
    tblFrame.origin.x -= tblFrame.size.width;
   
    [UIView animateWithDuration:2
                          delay:0.0
                        options: UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                        [self.tbvTableView setHidden:YES];
                         [self.tbvTableView setAlpha:0.8];
                         self.tbvTableView.frame = tblFrame;
                     }completion:^(BOOL finished){
                         [self.tbvTableView setAlpha:0.9];
                     }];

    //Do what you want here
}

-(void)timelineViewSwipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    
    CGRect tblFrame = self.tbvTableView.frame;
    tblFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
    CGRect temp = self.view.frame;
    temp.origin.x = 300;
    [UIView animateWithDuration:1
                          delay:0.0
                        options: UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                         [self.tbvTableView setAlpha:0.2];
                         self.tbvTableView.frame = tblFrame;
                     }completion:^(BOOL finished){
                         [self.tbvTableView setHidden:YES];
                     }];
    isSwipeRight = YES;

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
    }];
}

- (void)animationAppearView {
    
    [UIView animateWithDuration:1 animations:^{
        [_topView setAlpha:1];
        [_bottomView setAlpha:1];
        [_topView setHidden:NO];
        [_bottomView setHidden:NO];
    }];
}

- (IBAction)click_playlist:(id)sender {
    
    if(isSwipeRight) {
        
        if(_tbvTableView.frame.origin.x == [UIScreen mainScreen].bounds.size.width) {
            CGRect mainFrame = [[UIScreen mainScreen]bounds];
            CGRect tblFrame = self.tbvTableView.frame;
            tblFrame.origin.x = mainFrame.size.width - tblFrame.size.width;
            
            [UIView animateWithDuration:1
                                  delay:0.0
                                options: UIViewAnimationOptionOverrideInheritedCurve
                             animations:^{
                                 [self.tbvTableView setHidden:NO];
                                 [self.tbvTableView setAlpha:0.8];
                                 self.tbvTableView.frame = tblFrame;
                             }completion:^(BOOL finished){
                                 [self.tbvTableView setAlpha:0.9];
                             }];
        }else {
            CGRect tblFrame = self.tbvTableView.frame;
            tblFrame.origin.x += tblFrame.size.width;
            CGRect temp = self.view.frame;
            temp.origin.x = 300;
            [UIView animateWithDuration:1
                                  delay:0.0
                                options: UIViewAnimationOptionOverrideInheritedCurve
                             animations:^{
                                 [self.tbvTableView setAlpha:0.2];
                                 self.tbvTableView.frame = tblFrame;
                             }completion:^(BOOL finished){
                                 [self.tbvTableView setHidden:YES];
                             }];

        }
        
    }else {
        if(_tbvTableView.isHidden) {
            
            [UIView animateWithDuration:1.5 animations:^{
                [_tbvTableView setAlpha:0.9];
            }];
            [UIView animateWithDuration:0.5 animations:^{
                [_tbvTableView setHidden:NO];
            }];
        }else {
            [UIView animateWithDuration:2 animations:^{
                [_tbvTableView setAlpha:0.3];
            }];
            [UIView animateWithDuration:1 animations:^{
                [_tbvTableView setHidden:YES];
            }];
        }
    }
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






#pragma  mark  - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    YTTimelineViewCell * viewCell = (YTTimelineViewCell*)[tableView dequeueReusableCellWithIdentifier:@"playerTableViewCellIdentify"];
    if (viewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YTTimelineViewCell" owner:self options:nil];
        viewCell = [nib objectAtIndex:0];
    }
    viewCell.avartar.layer.borderWidth = 3.0f;
    viewCell.avartar.layer.borderColor = [UIColor colorWithHexString:@"#c1c1c1"].CGColor;
    viewCell.avartar.layer.cornerRadius = viewCell.avartar.frame.size.width / 2;
    viewCell.avartar.clipsToBounds = YES;
    [viewCell.txtTimeline setTextColor:[UIColor whiteColor]];
    [viewCell.txtSinger setTextColor:[UIColor whiteColor]];
    [viewCell.txtContentName setTextColor:[UIColor whiteColor]];
    
//    viewCell.txtTimeline.text = @"";
//    __weak UIImageView *imageView = viewCell.avartar;
//    [[DLImageLoader sharedInstance]loadImageFromUrl:@"" completed:^(NSError *error, UIImage *image) {
//        //            [imageView setImage:image];
//    }];
    
    return viewCell;
}



@end
