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

static void *AVPlayerViewControllerKeepUpObservationContext = &AVPlayerViewControllerKeepUpObservationContext;
static void *AVPlayerViewControllerBufferEmptyObservationContext = &AVPlayerViewControllerBufferEmptyObservationContext;
static void *YTPlayerAdPlayerItemStatusObservationContext = &YTPlayerAdPlayerItemStatusObservationContext;

@interface YTPlayerViewController ()
{
    BOOL seekToZeroBeforePlay;
    AVPlayer* playerVideo;
    AVPlayerItem* playerItemVideo;
    
    AVPlayerItem *playerItemAdv;
    AVPlayer *playerAdv;
    YTContent * contentObj;
    YTDetail * detail;
    BOOL isSwipeRight;
    NSNumber* playItemID;
    BOOL isSeeking;
    YTAdvInfo *currentAdvInfo;
    YTAdv *currentAdvObject;
    
    NSMutableArray * arrayButtonSchedule;
    
    
    
    NSTimer *scheduleDisplayAdv;
    NSTimer *scheduleCloseAdv;
    NSMutableArray *queueAdvItems;
    
    BOOL isPaused;;
    BOOL isPlaying;
    id playerTimerObserver;
    id advTimerObserver;
    id localTimer;
    id chromecastTimer;
    
    
    NSArray *listSchedule;
    NSArray *listTimeline;
    NSString * playItemNam;
    NSString * playItemUrl;
    BOOL isPlayingAdv;
    float mRestoreAfterScrubbingRate;
    
    __weak ChromecastDeviceController *chromecastController;
    
    double _currentTime,_advCurrentTime;
    int m_index_schedule, m_index_timeline;
}
@end

@implementation YTPlayerViewController


- (id)initWithID:(NSNumber*)ID {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        playItemID = ID;
        m_index_timeline = -1;
    }
    return self;
}


- (id)initWithIndexSchedule:(int)index_schedule indexTimeline:(int)index_timeline contentID:(NSNumber*)contentID{
    self = [self initWithID:contentID];
    if(self) {
        m_index_schedule = index_schedule;
        m_index_timeline = index_timeline;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initScrubberTimer];
    [self setUpGesture];
    
    chromecastController = [CHROMCAST_MANAGER chromcastCtrl];
    
    [self initSystemVolumn];
    [self.liveView.layer setBorderWidth:2];
    [self.liveView.layer setBorderColor:[UIColor colorWithHexString:@"5ea2fd"].CGColor];
    [_tbvTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self loadDataForPlayer];
    
    [chromecastController.deviceManager setVolume:0.0];
}

- (void)viewDidAppear:(BOOL)animated {
    chromecastController.delegate = self;
    [self hiddenNavigator];
}




#pragma mark - 


- (void)setUpGesture {
    
    UITapGestureRecognizer *playerViewTap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTapped:)];
    [playerViewTap setNumberOfTapsRequired:1];
    playerViewTap.delegate = self;
    [self.playerView addGestureRecognizer:playerViewTap];
    
    UITapGestureRecognizer *advImageView= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAdvImageView:)];
    [advImageView setNumberOfTapsRequired:1];
    advImageView.delegate = self;
    [self.imageAdvView addGestureRecognizer:advImageView];
    
    UITapGestureRecognizer *touchLiveView= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLiveViewTV:)];
    [touchLiveView setNumberOfTapsRequired:1];
    touchLiveView.delegate = self;
    [self.liveView addGestureRecognizer:touchLiveView];
    
    UITapGestureRecognizer *doubleTapGuestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerDoubleTapped:)];
    [doubleTapGuestureRecognizer setNumberOfTapsRequired:2];
    doubleTapGuestureRecognizer.delegate = self;
    [self.playerView addGestureRecognizer:doubleTapGuestureRecognizer];
    
    [playerViewTap requireGestureRecognizerToFail:doubleTapGuestureRecognizer];
    
    
    UISwipeGestureRecognizer * swipeLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(timelineViewSwipeRight:)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.playerView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(timelineViewSwipeRight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.playerView addGestureRecognizer:swiperight];
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
    self.btnCast.imageView.animationImages = @[[UIImage imageNamed:@"cast_white_on0"], [UIImage imageNamed:@"cast_white_on1"],[UIImage imageNamed:@"cast_white_on2"],[UIImage imageNamed:@"cast_white_on1"]];
    
    self.btnCast.imageView.animationDuration = 2;

    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)showStopButton{
    [_btnPlay setImage:[UIImage imageNamed:@"pause_iphone"] forState:UIControlStateNormal];
}

/* Show the play button in the movie player controller. */
-(void)showPlayButton{
    [_btnPlay setImage:[UIImage imageNamed:@"icon_player"] forState:UIControlStateNormal];
}

#pragma mark - timeline

- (void)loadScheduleTimeline {
    m_index_schedule = 0;
    listSchedule = contentObj.detail.timeline.allObjects;
    if(listSchedule.count >0) {
        YTTimeline *timeline = listSchedule[m_index_schedule];
        listTimeline = [NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline];
    }
}

- (void)addScheduleButton {
    if(listSchedule.count >0) {

        arrayButtonSchedule = [NSMutableArray array];
        for(int i=0;i<listSchedule.count;i++) {
            if(i > 2) {
                return ;
            }
            YTTimeline *timeline = listSchedule[i];
            UIButton *btnTimeline = [UIButton buttonWithType:UIButtonTypeSystem];
            [btnTimeline setTitle:timeline.title forState:UIControlStateNormal];
            [btnTimeline setFrame:CGRectMake(54 * i + 10, 3, 54, 30)];
            [btnTimeline setTag:i];
            [btnTimeline addTarget:self
                            action:@selector(click_scheduleButton:)
                  forControlEvents:UIControlEventTouchDown];
            if(i== m_index_schedule) {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:17]];
                [btnTimeline setTitleColor:[UIColor colorWithRed:161 green:161 blue:161 alpha:1] forState:UIControlStateNormal];
                btnTimeline.layer.borderWidth = 2.0f;
                btnTimeline.layer.borderColor = [UIColor colorWithHexString:@"5ea2fd"].CGColor;
                
                [self.liveView.layer setBorderColor:[UIColor colorWithHexString:@"5ea2fd"].CGColor];
            }else {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:17]];
                [btnTimeline setTitleColor:[UIColor colorWithRed:161 green:161 blue:161 alpha:1] forState:UIControlStateNormal];
                //        [btnTimeline setBackgroundColor:[UIColor whiteColor]];
                btnTimeline.layer.borderWidth = 2.0f;
                btnTimeline.layer.borderColor = [UIColor colorWithRed:161 green:161 blue:161 alpha:1].CGColor;
            }
            [arrayButtonSchedule addObject:btnTimeline];
            [self.scheduleView addSubview:btnTimeline];
        }
    }
}


- (void)click_scheduleButton:(UIButton *)sender {
    sender.layer.borderColor =[UIColor colorWithHexString:@"5ea2fd"].CGColor;
    UIButton *previousButton = arrayButtonSchedule[m_index_schedule];
    previousButton.layer.borderColor = [UIColor colorWithRed:161 green:161 blue:161 alpha:1].CGColor;
    m_index_schedule = (int)sender.tag;
    YTTimeline *timelineAtIndex = [listSchedule objectAtIndex:m_index_schedule];
    if(timelineAtIndex) {
        listTimeline = [NSKeyedUnarchiver unarchiveObjectWithData:timelineAtIndex.arrayTimeline];
        [UIView transitionWithView:self.tbvTableView
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void){
                            
                            [self.tbvTableView reloadData];
                        }completion:nil];
    }
}


- (void)hiddenNavigator {
    UINavigationController *navigatorCtrl =self.navigationController;
    [navigatorCtrl.navigationBar setHidden:YES];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}


- (void)loadDataForPlayer {
    
    [self.loadingView setHidden:NO];
    [self.loadingView startAnimating];
    
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:playItemID];
    BFTask *task = nil;
    if(contentObj.detail) {
        task = [BFTask taskWithResult:nil];
    }else {
        task = [DATA_MANAGER pullAndSaveContentDetail:playItemID];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:playItemID];
            detail = contentObj.detail;
            //done load data
            
            [self loadScheduleTimeline];
            [self addScheduleButton];
            
            if(m_index_timeline>-1 && contentObj.detail.timeline.allObjects > 0) {
                
                NSArray *arrayTimeline = [contentObj.detail.timeline allObjects];
                YTTimeline * timeline = arrayTimeline[m_index_schedule];
                if(timeline.arrayTimeline) {
                    NSDictionary *itemDict = [[NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline]objectAtIndex:m_index_timeline];
                    if(itemDict) {
                        playItemNam = [itemDict valueForKey:@"name"];
                        playItemUrl = [itemDict valueForKey:@"link"];
                        if([itemDict valueForKey:@"adv"]) {
                            NSArray *advs = [itemDict valueForKey:@"adv"];
                            queueAdvItems = [NSMutableArray array];
                            for(NSDictionary *advDict in advs) {
                                YTAdv *adv = [YTAdv MR_createEntity];
                                adv.link = [advDict valueForKey:@"link"];
                                adv.type = @([[advDict valueForKey:@"type"] intValue]);
                                adv.start = @([[advDict valueForKey:@"start"] intValue]);
                                adv.duration = @([[advDict valueForKey:@"duration"] intValue]);
                                adv.skip = @([[advDict valueForKey:@"skip"] intValue]);
                                adv.skipeTime = @([[advDict valueForKey:@"skippable_time"] intValue]);
                                [queueAdvItems addObject:adv];
                            }
                        }
                        [_txtTitle setText:contentObj.name];
                        [self prepareForPlayerView];
                        return nil;
                    }
                }
            }
            [self loadLocalAdv];
            playItemUrl = detail.link;
            playItemNam = contentObj.name;
            [_txtTitle setText:contentObj.name];
            
            
            [self prepareForPlayerView];
            
          }
        return nil;
    }];
}


- (void)initWithAudioMode {
    
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

- (void)audioSessionInterrupted:(NSNotification*)interruptionNotification {
    NSLog(@"interruption received: %@", interruptionNotification);
}
#pragma mark - player


- (void)prepareForPlayerView {
  
    [[self loadUrlAdv] continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            if(currentAdvObject.start.intValue == 0 && currentAdvObject.type.intValue == TypeVideo){ //play adv right now
                [self startPlayerAdv];
            }else {
                [self startPlayer];
            }
        }else {
            [self didFinishAdvPlayer];
        }
        return nil;
    }];
}

- (void)startPlayer {
    
    [self.loadingView setHidden:NO];
    [self.loadingView startAnimating];
    [self updateVolumeView];
    
    if (playItemUrl != nil)
    {
        if(chromecastController.isConnected) {
            NSString *url = playItemUrl;
            if ([contentObj.karaoke boolValue]) {
               
                url = [url stringByReplacingOccurrencesOfString:@"/index.m3u8" withString:@"/singer.m3u8"];
            }
            url = @"http://origin.onworldtv.com:1935/vodorigin/_definst_/series/Socola.Hay.Hoa.Hong/Socola.Hay.Hoa.Hong.2014.01.720p/index.m3u8?worldtokenstarttime=1438243720&worldtokenendtime=1438328320&worldtokenhash=XBmkiCtkJxnQZCaXKIZMyfteOnWG11w9WB6dW4AGbTI=";
            [self beginPlayVideo];
            if (contentObj.image && [contentObj.image length] > 0) {
                [chromecastController loadMedia:[NSURL URLWithString:url]
                                    thumbnailURL:[NSURL URLWithString:contentObj.image]
                                           title:playItemNam
                                        subtitle:@""
                                        mimeType:@"application/vnd.apple.mpegurl"
                                       startTime:_currentTime
                                        autoPlay:YES
                                           music:(contentObj.detail.mode == 0)];
            }
            else {
                [chromecastController loadMedia:[NSURL URLWithString:url]
                                    thumbnailURL:nil
                                           title:playItemNam
                                        subtitle:@""
                                        mimeType:@"application/vnd.apple.mpegurl"
                                       startTime:_currentTime
                                        autoPlay:YES
                                           music:(contentObj.detail.mode == 0)];
            }
            
            if (chromecastTimer) {
                [chromecastTimer invalidate];
                chromecastTimer = nil;
            }
            
            chromecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(updateInterfaceFromCast:)
                                                              userInfo:nil
                                                               repeats:YES];
        }else {
            NSURL *urlPath = [NSURL URLWithString:playItemUrl];
            if(urlPath) {
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:urlPath options:nil];
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
            }else {
                NSError *error = [NSError errorWithDomain:@"com.OnWorlPlayer.LoadingAsset" code:1 userInfo:nil];
                [self assetFailedToPrepareForPlayback:error];
            }
        }
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
    if (playerItemVideo)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [playerItemVideo removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:playerItemVideo];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    playerItemVideo = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [playerItemVideo addObserver:self
                       forKeyPath:kStatusKey
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:YTPlayerViewControllerStatusObservationContext];
    
    [playerItemVideo addObserver:self
                  forKeyPath:kPlaybackLikelyToKeepUp
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerViewControllerKeepUpObservationContext];
    [playerItemVideo addObserver:self
                  forKeyPath:kPlaybackBufferEmpty
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerViewControllerBufferEmptyObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItemVideo];
    
    seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!playerVideo)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        playerVideo = [AVPlayer playerWithPlayerItem:playerItemVideo];
//        [self setPlayer:[AVPlayer playerWithPlayerItem:mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [playerVideo addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:YTPlayerViewControllerCurrentItemObserverContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [playerVideo addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:YTPlayerViewControllerRateObserverContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (playerVideo.currentItem != playerItemVideo)
    {
        
        [playerVideo replaceCurrentItemWithPlayerItem:playerItemVideo];
        
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
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatusUnknown");
                [self removePlayerTimeObserver];
                [self syncScrubber];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [self.loadingView stopAnimating];
                [self.loadingView setHidden:YES];
                [playerVideo play];
                [self initScrubberTimer];
                [self beginPlayVideo];
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
            [self.playerView setPlayer:playerVideo];
            
            [self syncPlayPauseButtons];
        }
        
        
    }else if (context == AVPlayerViewControllerKeepUpObservationContext) {

        if (playerItemVideo.playbackLikelyToKeepUp) {
            [self.loadingView stopAnimating];
            [self.loadingView setHidden:YES];
            [self showStopButton];
        }
        else {
            [self.loadingView startAnimating];
            [self showPlayButton];
        }
    }
    else if (context == AVPlayerViewControllerBufferEmptyObservationContext) {

        if (playerItemVideo.playbackBufferEmpty) {
            [self.loadingView setHidden:YES];
            [self.loadingView stopAnimating];
            [self showStopButton];
        }else {
            [self.loadingView startAnimating];
            [self showPlayButton];
        }
    }
    else if(context == YTPlayerAdPlayerItemStatusObservationContext) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatusUnknown ===== ADV");
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"AVPlayerItemStatusReadyToPlay ===== ADV");
                [self.loadingView stopAnimating];
                [self.loadingView setHidden:YES];
                isPlayingAdv = YES;
                [UIView animateWithDuration:1 animations:^{
                    [self.playerView setPlayer:playerAdv];
                }];
                
                
                if(currentAdvObject.skip.intValue == 1) { // allow show button skip
                     scheduleCloseAdv = [NSTimer scheduledTimerWithTimeInterval:currentAdvObject.skipeTime.intValue
                                                                        target:self
                                                                      selector:@selector(timerDidSkipButton:)
                                                                      userInfo:nil
                                                                       repeats:NO];
                }
            }
            break;
                
            case AVPlayerItemStatusFailed:
            {
                [self didFinishAdvPlayer];
            }
            break;
        }
    }else {
        NSLog(@"AVPlayerItemStatusFailed =============");
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

- (void)syncPlayPauseButtons{
    
    if (![self isPlaying])
    {
        if(!isPaused) {
            [self.loadingView setHidden:NO];
            [self.loadingView startAnimating];
        }
        [self showPlayButton];
    }
    else
    {
        [self.btnPlay setEnabled:YES];
        [self.txtTimePlaying setEnabled:YES];
        [self.txtTotalTime setEnabled:YES];
        [self.sliderTrackView setEnabled:YES];
        [self showStopButton];
        [self.loadingView stopAnimating];
        [self.loadingView setHidden:YES];
    }
}


- (BOOL)isPlaying {
    if(chromecastController.isConnected) {
        return isPlaying;
    }else {
        return mRestoreAfterScrubbingRate != 0.f || [playerVideo rate] != 0.f;
    }
}

- (void)initScrubberTimer{
    
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
            NSString *txtInterVal = [YTOnWorldUtility stringWithTimeInterval:duration];
            [self.txtTotalTime setText:txtInterVal];
        }
        
        /* Update the scrubber during normal playback. */
        __weak YTPlayerViewController *weakSelf = self;
 
        playerTimerObserver = [playerVideo addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
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
        double time = CMTimeGetSeconds([playerVideo currentTime]);
        NSString *currentTime = [YTOnWorldUtility stringWithTimeInterval:time];
        [self.txtTimePlaying setText:currentTime];
        [self.sliderTrackView setValue:(maxValue - minValue) * time / duration + minValue];
    }
}


- (IBAction)beginScrubbing:(id)sender {
    isSeeking = YES;
    mRestoreAfterScrubbingRate = [playerVideo rate];
    [playerVideo setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

- (void)beginPlayVideo {
    
    isSeeking = NO;
    if(listSchedule.count >0) {
        [self.scheduleView setHidden:NO];
        [self.btnPlayList setEnabled:YES];
    }else {
        [self.scheduleView setHidden:YES];
        [self.btnPlayList setEnabled:NO];
    }
    if(detail.isLive.intValue == 1) {
        [self.liveView setHidden:NO];
        [self.liveView setAlpha:1];
        [self.sliderTrackView setHidden:YES];
        [self.txtTimePlaying setHidden:YES];
        [self.txtTotalTime setHidden:YES];
    }else {
        [self.liveView setHidden:YES];
        [self.sliderTrackView setHidden:NO];
        [self.txtTimePlaying setHidden:NO];
        [self.txtTotalTime setHidden:NO];
    }
    //show player view
    [self showPlayerView:YES];
    //load next adv
    [[self loadUrlAdv]continueWithBlock:^id(BFTask *task) {
        // schedul for next adv
        [self scheduleTimerForAdvPlayer];
        return nil;
    }];
}

- (BOOL)isScrubbing {
    return mRestoreAfterScrubbingRate != 0.f;
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender {
//    if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
//    {
//        isSeeking = YES;
//        UISlider* slider = sender;
//        
//        CMTime playerDuration = [self playerItemDuration];
//        if (CMTIME_IS_INVALID(playerDuration)) {
//            return;
//        }
//        
//        double duration = CMTimeGetSeconds(playerDuration);
//        if (isfinite(duration))
//        {
//            float minValue = [slider minimumValue];
//            float maxValue = [slider maximumValue];
//            float value = [slider value];
//            
//            double time = duration * (value - minValue) / (maxValue - minValue);
//            
//            [playerVideo seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    isSeeking = NO;
//                });
//            }];
//        }
//    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */

- (IBAction)endScrubbing:(id)sender {
    
    if (!localTimer) {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
           __weak YTPlayerViewController *weakSelf = self;
            localTimer = [playerVideo addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.2f, NSEC_PER_SEC) queue:NULL usingBlock:
                           ^(CMTime time)
                           {
                               [weakSelf syncScrubber];
                           }];
            float value = [self.sliderTrackView value];
            float minValue = [self.sliderTrackView minimumValue];
            float maxValue = [self.sliderTrackView maximumValue];
            
            [playerVideo seekToTime:CMTimeMakeWithSeconds(value, NSEC_PER_SEC)];
            [playerVideo play];
        }
    }
    

}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [playerVideo currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}



-(void)removePlayerTimeObserver {
    if (playerTimerObserver)
    {
        [playerVideo removeTimeObserver:playerTimerObserver];
        playerTimerObserver = nil;
    }
}

#pragma mark - notification  player Item

- (void)videoAdvPlayerItemDidReachEnd:(NSNotification *)notification {
    [self didFinishAdvPlayer];
}

- (void)videoAdPlayerItemFailedToReachEnd:(NSNotification *)notification {
    [self didFinishAdvPlayer];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    /* After the movie has played to its end time, seek back to time zero
     to play it again.*/
    seekToZeroBeforePlay = YES;
    [playerVideo seekToTime:kCMTimeZero];
    [self syncScrubber];
    [self showPlayButton];
    [self stopCurrentPlayer];
}

- (void)showVideoAdvView:(BOOL)flag {
    [UIView animateWithDuration:1 animations:^{
        if(!flag) {
            [self.topViewAdv setAlpha:0.0];
            [self.bottomViewAdv setAlpha:0.0];
        }else {
            [self.topViewAdv setAlpha:0.8];
            [self.bottomViewAdv setAlpha:0.8];
        }
        [self.topViewAdv setHidden:!flag];
        [self.bottomViewAdv setHidden:!flag];
    }];
}

- (void)showPlayerView:(BOOL)flag{
    
    [UIView animateWithDuration:1 animations:^{
        if(!flag) {
            [self.topView setAlpha:0.0];
            [self.bottomView setAlpha:0.0];
            [self.scheduleView setAlpha:0.0];
        }else {
            [self.topView setAlpha:0.8];
            [self.bottomView setAlpha:0.8];
            [self.scheduleView setAlpha:0.8];
        }
        [self.topView setHidden:!flag];
        [self.bottomView setHidden:!flag];
        if(listSchedule.count >0 && flag) {
            [self.scheduleView setHidden:NO];
        }else{
            [self.scheduleView setHidden:YES];
        }
    }];
    
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

- (void)scheduleTimerForAdvPlayer {
    if(queueAdvItems.count > 0 && currentAdvObject) {
        NSTimeInterval interval = currentAdvObject.start.intValue;
        scheduleDisplayAdv = [NSTimer scheduledTimerWithTimeInterval:interval
                                                              target:self
                                                            selector:@selector(timerDidDisplayAdv:)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}

- (void)timerDidDisplayAdv:(NSTimer *)timer {
    
    [scheduleDisplayAdv invalidate];
    scheduleDisplayAdv = nil;
    //
    if(currentAdvObject.type.intValue == TypeVideo) {
        if(playerVideo) {
            [playerVideo pause];
        }
        [self showPlayerView:NO];
        [self startPlayerAdv];
        
    }else {
        
        [UIView animateWithDuration:1 animations:^{
            [self.imgAdvView setHidden:NO];
            [self.btnCloseImageViewAdv setHidden:NO];
            __weak UIImageView *imageView = self.imageAdvView;
            
            [self.imageAdvView sd_setImageWithURL:[NSURL URLWithString:currentAdvInfo.url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
           
        }];
    }
}

- (void)timerDidSkipButton:(NSTimer *)timer {
    [scheduleCloseAdv invalidate];
    scheduleCloseAdv = nil;
    
    if(currentAdvObject.type.intValue == TypeVideo) {
        [self.bottomViewAdv setHidden:NO];
        [self.btnSkip setHidden:NO];
    }
}





#pragma mark - gesture


- (void)playerTapped:(UITapGestureRecognizer *)sender {
    if(!isPlayingAdv) {
        if(_topView.isHidden) {
            [self showPlayerView:YES];
        }else {
            [self showPlayerView:NO];
        }
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAdvInfo.touchLink]];
    }
}


- (void)clickAdvImageView:(UITapGestureRecognizer *)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:currentAdvInfo.touchLink]];
    
}


-(void)timelineViewSwipeRight:(UISwipeGestureRecognizer*)gestureRecognizer {
    if(!isPlayingAdv) {
        if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            if([UIScreen mainScreen].bounds.size.width <self.scheduleView.frame.origin.x + self.scheduleView.frame.size.width) { // showing
                CGRect frame = self.scheduleView.frame;
                frame.origin.x -= frame.size.width;
                [UIView animateWithDuration:1 animations:^{
                    [self.scheduleView setFrame:frame];
                }];
            }
        }else if(gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            if([UIScreen mainScreen].bounds.size.width >=self.scheduleView.frame.origin.x + self.scheduleView.frame.size.width) {
                CGRect frame = self.scheduleView.frame;
                frame.origin.x += frame.size.width;
                [UIView animateWithDuration:1 animations:^{
                    [self.scheduleView setFrame:frame];
                }];
            }
        }
    }
}

- (void)clickLiveViewTV:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (detail) {
        if(playerVideo) {
            [playerVideo pause];
            [self.loadingView setHidden:NO];
            [self.loadingView startAnimating];
        }
        [self stopCurrentPlayer];
        playItemUrl = detail.link;
        playItemNam = contentObj.name;
        [self loadLocalAdv];
        [self prepareForPlayerView];
    }
}


- (void)playerDoubleTapped:(UITapGestureRecognizer *)sender {
   
    if ([[self.playerView getVideoFillMode] isEqualToString:AVLayerVideoGravityResizeAspectFill])
        [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    else{
        [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
    }
}

- (IBAction)click_closePlayer:(id)sender {
    
    [self stopChromecastDevice];
    
    UINavigationController *navigatorCtrl =self.navigationController;
    [navigatorCtrl.navigationBar setHidden:NO];
    
    [self stopCurrentPlayer];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (void)stopChromecastDevice {
    if(chromecastController) {
        [chromecastController stopCastMedia];
        chromecastController.delegate = nil;
        [chromecastTimer invalidate];
        chromecastTimer = nil;
    }
}

- (void)didFinishAdvPlayer {
//     remove previous adv
    
    isPlayingAdv = NO;
    [self showVideoAdvView:NO];
    if(queueAdvItems.count >0){
        [queueAdvItems removeObjectAtIndex:0];
        currentAdvInfo = nil;
        currentAdvObject = nil;
        [self nextAdv];
    }
    
    [UIView animateWithDuration:1 animations:^{
        [self.topViewAdv setHidden:YES];
        [self.bottomViewAdv setHidden:YES];
    }];
    // release adv notification
    [self releasePlayerAdv];
    // begin player
    if(playerVideo) {
        [playerVideo play];
    }else {
        [self startPlayer];
    }
}

- (void)releasePlayerAdv {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                 object:nil];
    if(playerItemAdv){
        [playerItemAdv removeObserver:self forKeyPath:kStatusKey];
        
    }
    if (advTimerObserver)
    {
        [playerAdv removeTimeObserver:advTimerObserver];
        advTimerObserver = nil;
    }
}

- (void)stopCurrentPlayer {
    
    [self removePlayerTimeObserver];

    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:nil];
    
    if(playerItemVideo) {
        [playerItemVideo removeObserver:self forKeyPath:kStatusKey];
        [playerItemVideo removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
        [playerItemVideo removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    }
    playerItemVideo = nil;
    
    if(playerVideo) {
        [playerVideo removeObserver:self forKeyPath:kRateKey];
        [playerVideo removeObserver:self forKeyPath:kCurrentItemKey];
    }
    playerVideo = nil;
}

- (IBAction)click_cast:(id)sender {
    
}

- (IBAction)click_playlist:(id)sender {
    
    if([UIScreen mainScreen].bounds.size.width <self.scheduleView.frame.origin.x + self.scheduleView.frame.size.width) { // showing
        CGRect frame = self.scheduleView.frame;
        frame.origin.x -= frame.size.width;
        [UIView animateWithDuration:1 animations:^{
            [self.scheduleView setFrame:frame];
        }];
    }else {
        CGRect frame = self.scheduleView.frame;
        frame.origin.x += frame.size.width;
        [UIView animateWithDuration:1 animations:^{
            [self.scheduleView setFrame:frame];
        }];
    }
}

- (IBAction)click_play:(id)sender {
    
    if(chromecastController.isConnected) {
        if ([self isPlaying])
            [chromecastController pauseCastMedia:YES];
        else
            [chromecastController pauseCastMedia:NO];
    }else {
        
        if([self isPlaying]) {
            [playerVideo pause];
            isPaused = YES;
        }else {
            isPaused = NO;
            if (YES == seekToZeroBeforePlay)
            {
                seekToZeroBeforePlay = NO;
                [playerVideo seekToTime:kCMTimeZero];
            }
            [playerVideo play];
        }
    }
}

- (IBAction)click_closeAdvImageView:(id)sender {
    [UIView animateWithDuration:1 animations:^{
        [self.imgAdvView setHidden:YES];
        [self.btnCloseImageViewAdv setHidden:YES];
    }];

}

- (IBAction)click_skip:(id)sender {
    [self didFinishAdvPlayer];
}

- (IBAction)click_AdvView:(id)sender {
    
}

#pragma mark - adv 


- (void)startPlayerAdv {
    
    if(queueAdvItems.count == 0)
        return ;
    [self.topViewAdv setHidden:NO];
    [self.bottomViewAdv setHidden:YES];
    if(currentAdvObject!=nil) {
        if(currentAdvObject.type.intValue == TypeVideo){
            
            isPlayingAdv = YES;
            if(chromecastController.isConnected) {
                [chromecastController loadMedia:[NSURL URLWithString:currentAdvInfo.url]
                                    thumbnailURL:nil
                                           title:@""
                                        subtitle:@""
                                        mimeType:@"application/vnd.apple.mpegurl"
                                       startTime:_advCurrentTime
                                        autoPlay:YES
                                           music:NO];
                
                if (chromecastTimer) {
                    [chromecastTimer invalidate];
                    chromecastTimer = nil;
                }
                
                chromecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target:self
                                                                  selector:@selector(updateInterfaceFromCast:)
                                                                  userInfo:nil
                                                                   repeats:YES];
            }else {
                [self showVideoAdvView:YES];
                [self showPlayerView:NO];
                NSURL *url = [NSURL URLWithString:currentAdvInfo.url];
                
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
                advTimerObserver= [playerAdv addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {
                    
                    int i = (int)(currentAdvInfo.duration - CMTimeGetSeconds(playerAdv.currentTime));
                    if (i >= 0) {
                        NSString *lbAdvSecond = [NSString stringWithFormat:@"This ad will close in %d", i];
                        [weakSelf.lbAdvSecondTime setText:lbAdvSecond];
                    }
                    else {
                        [weakSelf.lbAdvSecondTime setText:@""];
                    }
                }];
                [playerVideo pause];
                [playerAdv play];
            }
        }
    }else if (currentAdvObject.type.intValue == TypeImage) {
        // schedule to sho image
        [self scheduleTimerForAdvPlayer];
        
    }
    
}


- (void)updateInterfaceFromCast:(NSTimer *)timer {
    [chromecastController updateStatsFromDevice];
    if (chromecastController.playerState == GCKMediaPlayerStateBuffering) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
    
    if(isPlayingAdv) {
        if (chromecastController.streamDuration > 0) {
            _advCurrentTime = chromecastController.streamPosition;
            double time = floor(_advCurrentTime);
            int i = (int)(currentAdvInfo.duration - time);
            if (i >= 0) {
                NSString *lbAdvSecond = [NSString stringWithFormat:@"This ad will close in %d", i];
                [self.lbAdvSecondTime setText:lbAdvSecond];
            }
            else {
                [self.lbAdvSecondTime setText:@""];
            }
        }else {
            NSLog(@"adv player :%f",chromecastController.streamDuration);
        }
        if (chromecastController.playerState == GCKMediaPlayerStateIdle && chromecastController.mediaControlChannel.mediaStatus.idleReason == GCKMediaPlayerIdleReasonFinished) {
            NSLog(@"Finish play adv");
            [self didFinishAdvPlayer];
        }
    }else {
        if (chromecastController.streamDuration > 0) {
             NSLog(@"video player %f",chromecastController.streamPosition);
            if (![self isScrubbing]) {
                if (self.sliderTrackView.hidden) {
                    self.sliderTrackView.minimumValue = 0.f;
                    self.sliderTrackView.maximumValue = chromecastController.streamDuration;
                    self.sliderTrackView.hidden = NO;
                }
                else {
                    double time = chromecastController.streamPosition;
                    float minValue = self.sliderTrackView.minimumValue;
                    float maxValue = self.sliderTrackView.maximumValue;
                    self.sliderTrackView.value = minValue + (maxValue - minValue) * time / chromecastController.streamDuration;
                    self.txtTimePlaying.text = [YTOnWorldUtility stringWithTimeInterval:time];
                    self.txtTotalTime.text = [YTOnWorldUtility stringWithTimeInterval:(chromecastController.streamDuration)];
                }
            }
        }
        else {
            self.sliderTrackView.hidden = YES;
            self.sliderTrackView.minimumValue = 0.f;
        }
        
        if (chromecastController.playerState == GCKMediaPlayerStatePaused ||
            chromecastController.playerState == GCKMediaPlayerStateIdle) {
            isPlaying = NO;
            [self showPlayButton];
        } else if (chromecastController.playerState == GCKMediaPlayerStatePlaying ||
                   chromecastController.playerState == GCKMediaPlayerStateBuffering) {
            isPlaying = YES;
            [self showStopButton];
        }
    }
}

- (void)loadLocalAdv {
    
    NSArray *advs = [contentObj.detail.adv allObjects];
    NSSortDescriptor *sortStart = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
    queueAdvItems  = [[NSMutableArray alloc]initWithArray:[advs sortedArrayUsingDescriptors:@[sortStart]]];
    if(queueAdvItems.count >0) {
        currentAdvObject = queueAdvItems [0];
    }
}

- (BFTask *)loadUrlAdv{
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [[DATA_MANAGER advInfoWithURLString:currentAdvObject.link] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            [completionSource setError:task.error];
        }else {
            currentAdvInfo = task.result;
            [completionSource setResult:nil];
        }
        return nil;
    }];
    return completionSource.task;
}

-(void)nextAdv {
    if(queueAdvItems.count > 0) {
        currentAdvObject = queueAdvItems[0];
    }else {
        currentAdvInfo = nil;
        currentAdvObject = nil;
    }
}

- (void)playNewVideo {
    // stop current video
    [self stopCurrentPlayer];
    
    // play new video
    [self startPlayer];
}


#pragma  mark  - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTimeline.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *timeDic = listTimeline[indexPath.row];
    
    YTTimelineViewCell * viewCell = (YTTimelineViewCell*)[tableView dequeueReusableCellWithIdentifier:@"playerTableViewCellIdentify"];
    if (viewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YTTimelineViewCell" owner:self options:nil];
        viewCell = [nib objectAtIndex:0];
    }
    viewCell.avartar.layer.borderWidth = 2.0f;
    viewCell.avartar.layer.borderColor = [UIColor colorWithHexString:@"#c1c1c1"].CGColor;
    viewCell.avartar.layer.cornerRadius = viewCell.avartar.frame.size.width / 2;
    viewCell.avartar.clipsToBounds = YES;
   
    /*
     name	:	Bird Nest Collagen
     image	:	http://img.onworldtv.com/wxh/timeline/2015/04/07/510768-ITV-homeshopping.jpg
     description	:
     link	:	http://204.9.200.244/sata/itv/Bird.Nest.Collagen.720p/index.m3u8
     start	:	00:00:00
     end	:	00:02:30
     */
    
    viewCell.txtContentName.text = [timeDic valueForKey:@"name"];
    viewCell.txtTimeline.text = [NSString stringWithFormat:@"%@ - %@",[timeDic valueForKey:@"start"],[timeDic valueForKey:@"end"]];
    viewCell.txtSinger.text = [timeDic valueForKey:@"description"];
    [viewCell.avartar sd_setImageWithURL:[NSURL URLWithString:[timeDic valueForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *timelinedict = listTimeline[indexPath.row];
    if(timelinedict) {
        playItemNam = [timelinedict valueForKey:@"name"];
        playItemUrl = [timelinedict valueForKey:@"link"];

        if([timelinedict valueForKey:@"adv"]) {
            NSArray *advs = [timelinedict valueForKey:@"adv"];
            queueAdvItems = [NSMutableArray array];
            for(NSDictionary *advDict in advs) {
                YTAdv *adv = [YTAdv MR_createEntity];
                adv.link = [advDict valueForKey:@"link"];
                adv.type = @([[advDict valueForKey:@"type"] intValue]);
                adv.start = @([[advDict valueForKey:@"start"] intValue]);
                adv.duration = @([[advDict valueForKey:@"duration"] intValue]);
                adv.skip = @([[advDict valueForKey:@"skip"] intValue]);
                adv.skipeTime = @([[advDict valueForKey:@"skippable_time"] intValue]);
                if(adv) {
                    [queueAdvItems addObject:adv];
                }
            }
        }
        [self stopCurrentPlayer];
        if(queueAdvItems.count >0) {
            [self nextAdv];
            [self prepareForPlayerView];
        }else {
             [self playNewVideo];
        }
    }
}


#pragma mark - Chromcast


- (void)didDiscoverDeviceOnNetwork
{
    
    self.btnCast.enabled = NO;
}


- (void)didDisconnect
{
    NSLog(@"%s",__FUNCTION__);
    [playerVideo pause];
    [playerAdv pause];
    [chromecastController stopCastMedia];
    
    if (chromecastTimer) {
        [chromecastTimer invalidate];
        chromecastTimer = nil;
    }
    
    [self.btnCast.imageView stopAnimating];
    
    if (!isPlayingAdv) {
        [self startPlayerAdv];
    }
    else {
        _currentTime = [self.sliderTrackView value];
        [self startPlayer];
    }
}

- (void)didConnectToDevice:(GCKDevice *)device
{
    NSLog(@"%s",__FUNCTION__);
    [playerVideo pause];
    [playerAdv pause];
    [self removePlayerTimeObserver];
    [self.btnCast setEnabled:YES];
    [self.btnCast.imageView stopAnimating];
    [self.btnCast setImage:[UIImage imageNamed:@"cast_on"] forState:UIControlStateNormal];
    if (!isPlayingAdv) {
        _advCurrentTime = CMTimeGetSeconds(playerAdv.currentTime);
        [self startPlayerAdv];
    }
    else {
        _currentTime = [self.sliderTrackView value];
        [self startPlayer];
    }
}

- (void)doConnecting:(GCKDevice *)device
{
    NSLog(@"%s",__FUNCTION__);
    [self.btnCast.imageView startAnimating];
}


- (void)playOrPause:(id)sender
{
    if (chromecastController.isConnected) {
        if ([self isPlaying])
            [chromecastController pauseCastMedia:YES];
        else
            [chromecastController pauseCastMedia:NO];
    }
    else {
        if ([self isPlaying]) {
            [playerVideo pause];
        }
        else {
            [playerVideo play];
        }
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (isPlayingAdv) return;
    
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playOrPause:nil];
                break;
            default:
                break;
        }
    }
}


#pragma mark --- volume

- (IBAction)volumeChanged:(id)sender {
    if (chromecastController.isConnected) {
        float idealVolume = self.slidervolume.value / 10.0f;
        idealVolume = MIN(1.0, MAX(0.0, idealVolume));
        
        [chromecastController.deviceManager setVolume:idealVolume];
    }
}

- (void)updateVolumeView
{
    if (chromecastController.isConnected) {
        self.volumnView.hidden = YES;
        self.slidervolume.hidden = NO;
        self.slidervolume.value = chromecastController.deviceMuted ? 0.0 : chromecastController.deviceVolume*10.0f;
    }
    else {
        self.volumnView.hidden = NO;
        self.slidervolume.hidden = YES;
    }
}

@end
