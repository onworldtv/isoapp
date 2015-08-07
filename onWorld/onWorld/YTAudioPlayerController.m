//
//  YTAudioPlayerController.m
//  OnWorld
//
//  Created by yestech1 on 7/16/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTAudioPlayerController.h"
#import "YTAdvInfo.h"
#import "YTPlayerView.h"


static void *itemRateContext = &itemRateContext;
static void *itemStatusContext = &itemStatusContext;
static void *itemCurrentContext = &itemCurrentContext;
static void *itemkeepUpContext = &itemkeepUpContext;
static void *itemBufferEmptyContext = &itemBufferEmptyContext;
static void *itemAdvContext = &itemAdvContext;



@interface YTAudioPlayerController (){
    NSNumber * contentID;
    id timerObserver;
    YTContent *contentObj;
    YTDetail *detail;
    id playerTimerObserver,localTimer, advTimerObserver;
    float mRestoreAfterScrubbingRate;
    
    
    YTAdvInfo *currnetAdvInfo;
    AVPlayer *advPlayer;
    AVPlayerItem  *advPlayerItem;
    
    ChromecastDeviceController *chromecastManager;
    id chromecastTimer;
    
    YTAdv * currentAdvObject;
    NSMutableArray * m_adv;
    
    BOOL isPlayingAdv;
    
    NSTimer *timer;
    NSTimer *timerSkip;
}

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;
@end

@implementation YTAudioPlayerController

- (id)initWithID:(NSNumber*)ID {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        contentID = ID;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    chromecastManager = CHROMCAST_MANAGER.chromcastCtrl;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigarbar"] forBarMetrics:UIBarMetricsDefault];
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    
    
    
    [self initSystemVolumn];
    [self sharedSession]; // set app run backgroud
    
    BFTask *task = nil;
    
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:contentID];
    if(contentObj) {
        task =[BFTask taskWithResult:nil];
    }else {
        task = [[DATA_MANAGER pullAndSaveContentDetail:contentID] continueWithBlock:^id(BFTask *task) {
            contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:contentID];
            return nil;
        }];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        
        [self setHiddenLoadingView:NO];
        [self bindingData];
        [self loadAdvData];
        [[self parserAdvInfo] continueWithBlock:^id(BFTask *task) {
            if(currnetAdvInfo) {
                if(currentAdvObject.type.intValue == TypeVideo && currentAdvObject.start.intValue == 0) { // play adv
                    [self startAdv];
                }else {
                    [self startAudio];
                }
            }else {
                [self didFinishAdv];
            }
            return nil;
        }];
        return nil;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    AVPlayerItem *playerItem = self.queuePlayer.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [self removePlayerTimeObserver];
    [self.queuePlayer removeAllItems];
    [self.queuePlayer pause];
    
    if(chromecastManager) {
        if(chromecastManager.isConnected) {
            [chromecastManager stopCastMedia];
            if(chromecastTimer) {
                [chromecastTimer invalidate];
                chromecastTimer = nil;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}


- (void)bindingData {
    _txtSongName.text = contentObj.name;
    _txtSigerName.text = @"";
}




- (void)sharedSession {
    
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


#pragma mark - volume view

- (void)updateVolumeView{
    if (CHROMCAST_MANAGER.chromcastCtrl.isConnected) {
        self.sliderVolume.hidden = YES;
        self.sliderVolume.hidden = NO;
        self.sliderVolume.value = CHROMCAST_MANAGER.chromcastCtrl.deviceMuted ? 0.0 : CHROMCAST_MANAGER.chromcastCtrl.deviceVolume*10.0f;
    }
    else {
        self.sliderVolume.hidden = NO;
        self.sliderVolume.hidden = YES;
    }
}

- (void)initSystemVolumn {
    
    _systemVolume.showsVolumeSlider = YES;
    _systemVolume.showsRouteButton = NO;
    for (UIView *vw in _systemVolume.subviews) {
        if ([vw isKindOfClass:[UISlider class]]) {
            [((UISlider*)vw) setMinimumValueImage:[UIImage imageNamed:@"music_mute_iphone"]];
            [((UISlider*)vw) setMaximumValueImage:[UIImage imageNamed:@"music_sound_iphone"]];
        }
    }
    
}




#pragma mark - chromecast
- (void)updateViewToPlayChromecastDevice {
    
    if(chromecastManager.isConnected) {
        self.sliderVolume.hidden = NO;
        self.systemVolume.hidden = YES;
    }else {
        self.sliderVolume.hidden = YES;
        self.systemVolume.hidden = NO;
    }
    
}

- (void)updateInterfaceMusicPlayer:(NSTimer *)timer {
    
    if(CHROMCAST_MANAGER.chromcastCtrl.isConnected) {
        NSLog(@"%f",chromecastManager.streamDuration);
        if (chromecastManager.streamDuration > 0) {
            NSLog(@"%f",chromecastManager.streamPosition);
            if (![self isScrubbing]) {
                if (self.sliderSeek.hidden) {
                    self.sliderSeek.minimumValue = 0.f;
                    self.sliderSeek.maximumValue = chromecastManager.streamDuration;
                    self.sliderSeek.hidden = NO;
                }
                else {
                    double time = chromecastManager.streamPosition;
                    float minValue = self.sliderSeek.minimumValue;
                    float maxValue = self.sliderSeek.maximumValue;
                    self.sliderSeek.value = minValue + (maxValue - minValue) * time / chromecastManager.streamDuration;
                    self.txtcurrentTime.text = [YTOnWorldUtility stringWithTimeInterval:time];
                    self.txtDuration.text = [YTOnWorldUtility stringWithTimeInterval:(chromecastManager.streamDuration - time)];
                }
            }
        }else {
            self.sliderSeek.hidden = YES;
            self.sliderSeek.minimumValue = 0.f;
            self.txtcurrentTime.hidden = YES;
            self.txtDuration.hidden = YES;
        }
        
        
        if (chromecastManager.playerState == GCKMediaPlayerStatePaused ||
            chromecastManager.playerState == GCKMediaPlayerStateIdle) {
            [self showPlayButton];
        } else if (chromecastManager.playerState == GCKMediaPlayerStatePlaying ||
                   chromecastManager.playerState == GCKMediaPlayerStateBuffering) {
            [self showStopButton];
        }
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = [self.queuePlayer currentItem];
    if(context == itemStatusContext) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusFailed: {
                [self didFinishAudioPlayerItem];
                NSLog(@"AVPlayerItemStatusFailed");
            }
            
            break;
            case AVPlayerItemStatusReadyToPlay:{
                [self setHiddenLoadingView:YES];
                [self.queuePlayer play];
                [self initScrubberTimer];
                if(currentAdvObject)
                    [self scheduleTimerDisplayAdv];
                
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            }
            break;
                
            default:
                break;
        }
    }else if (context == itemkeepUpContext) {
        if (playerItem.playbackLikelyToKeepUp) {
            [self.loadingView stopAnimating];
            [self.loadingView setHidden:YES];
            [self showStopButton];
        }
        else {
            [self showPlayButton];
        }
    }else if (context == itemBufferEmptyContext) {
        if (playerItem.playbackBufferEmpty) {
            [self.loadingView setHidden:YES];
            [self.loadingView stopAnimating];
            [self showStopButton];
        }else {
            [self.loadingView setHidden:NO];
            [self.loadingView startAnimating];
            [self showPlayButton];
        }

    }else if (context == itemRateContext) {
        [self syncPlaybutton];
    }else if (context == itemCurrentContext) {
        
    }else if (context == itemAdvContext) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusFailed: {
                [self didFinishAdv];
                NSLog(@"adv - AVPlayerItemStatusFailed");
            }
                
            break;
            case AVPlayerItemStatusReadyToPlay:{
                NSLog(@"adv - AVPlayerItemStatusReadyToPlay");
                [self setHiddenLoadingView:YES];
                [advPlayer play];
                isPlayingAdv = YES;
                
                if(currentAdvObject.skip.intValue == 1) { // allow show button skip
                    timerSkip = [NSTimer scheduledTimerWithTimeInterval:currentAdvObject.skipeTime.intValue
                                                                        target:self
                                                                      selector:@selector(timerAppearSkipButton:)
                                                                      userInfo:nil
                                                                       repeats:NO];
                }

            }
                break;
                
            default:
                break;
        }
    }
    
    
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)removePlayerTimeObserver{
    if (playerTimerObserver)
    {
        [self.queuePlayer removeTimeObserver:playerTimerObserver];
        playerTimerObserver = nil;
    }
   
}



#pragma mark - audio 

- (void)startAudio {
    
    if(contentObj) {
        
        if(CHROMCAST_MANAGER.chromcastCtrl.isConnected) {
            
            NSURL *urlPath = [NSURL URLWithString:contentObj.detail.link];
            if (contentObj.image && [contentObj.image length] > 0) {
                [CHROMCAST_MANAGER.chromcastCtrl loadMedia:urlPath
                                              thumbnailURL:[NSURL URLWithString:contentObj.image]
                                                     title:contentObj.name
                                                  subtitle:@""
                                                  mimeType:@"application/vnd.apple.mpegurl"
                                                 startTime:0
                                                  autoPlay:YES
                                                     music:(contentObj.detail.mode == 0)];
            }
            else {
                [CHROMCAST_MANAGER.chromcastCtrl loadMedia:urlPath
                                              thumbnailURL:nil
                                                     title:contentObj.name
                                                  subtitle:@""
                                                  mimeType:@"application/vnd.apple.mpegurl"
                                                 startTime:0
                                                  autoPlay:YES
                                                     music:(contentObj.detail.mode == 0)];
            }
            
            if (chromecastTimer) {
                [chromecastTimer invalidate];
                chromecastTimer = nil;
            }
            
            chromecastTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateInterfaceMusicPlayer:)
                                                             userInfo:nil
                                                              repeats:YES];
        }
        else {
            [self setHiddenLoadingView:NO];
            NSURL *url = [NSURL URLWithString:contentObj.detail.link];
            AVPlayerItem *adPlayerItem = [[AVPlayerItem alloc] initWithURL:url];
            
            self.queuePlayer = [[AVQueuePlayer alloc]initWithItems:@[adPlayerItem]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioPlayerDidFinish:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:adPlayerItem];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(audioLoadPlayerFailured:)
                                                         name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                       object:adPlayerItem];
            

            
            /* Observe the AVPlayer "rate" property to update the scrubber control. */
            [advPlayer addObserver:self
                          forKeyPath:@"rate"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:itemRateContext];
            [advPlayer addObserver:self
                          forKeyPath:@"currentItem"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:itemCurrentContext];
            
            [adPlayerItem addObserver:self forKeyPath:@"status"
                              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                              context:itemStatusContext];
            
            [adPlayerItem addObserver:self
                           forKeyPath:@"playbackLikelyToKeepUp"
                              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              context:itemkeepUpContext];
            
            [adPlayerItem addObserver:self
                           forKeyPath:@"playbackBufferEmpty"
                              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              context:itemBufferEmptyContext];
        }
    }else {
        [self didFinishAudioPlayerItem];
    }
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:contentObj.image] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)audioPlayerDidFinish:(NSNotification*)notification {
    [self didFinishAudioPlayerItem];
}

- (void)audioLoadPlayerFailured:(NSNotification *)notification {
    [self didFinishAudioPlayerItem];
}

- (void)didFinishAudioPlayerItem {
    
    [self removePlayerTimeObserver];
    
    if(self.queuePlayer) {
        [self.queuePlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [self.queuePlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.queuePlayer.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    }
    
    if(self.queuePlayer.items.count > 0) {
        [self.queuePlayer advanceToNextItem];
    }else {
        
    }
    [self.queuePlayer seekToTime:kCMTimeZero];
    [self.sliderSeek setValue:0.0];
    [self.txtcurrentTime setText:@"00:00:00"];
    [self syncScrubber];
    [self showPlayButton];
}



#pragma mark - seek

- (IBAction)beginScrubbing:(id)sender{
    mRestoreAfterScrubbingRate = [self.queuePlayer rate];
    [self.queuePlayer setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

- (BOOL)isScrubbing{
    return mRestoreAfterScrubbingRate != 0.f;
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender{
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender{
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
       __weak YTAudioPlayerController *weakSelf = self;
        localTimer = [self.queuePlayer  addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.2f, NSEC_PER_SEC) queue:NULL usingBlock:
                      ^(CMTime time)
                      {
                          [weakSelf syncScrubber];
                      }];
        float value = [self.sliderSeek value];
        float minValue = [self.sliderSeek minimumValue];
        float maxValue = [self.sliderSeek maximumValue];
        double time = duration * (value - minValue) / (maxValue - minValue);
        
        [self.queuePlayer  seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        [self.queuePlayer  play];
    }
}


#pragma mark - Scrubber

- (void)initScrubberTimer{
    //    if(detail.isLive.intValue == 0) {
    double interval = .1f;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        [self.txtDuration setHidden:YES];
        [self.txtcurrentTime setHidden:YES];
        [self.sliderSeek setHidden:YES];
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.sliderSeek bounds]);
        interval = 0.5f * duration / width;
        NSString *txtInterVal = [YTOnWorldUtility stringWithTimeInterval:duration];
        [self.txtDuration setText:txtInterVal];
    }else {
        [self.txtDuration setHidden:YES];
        [self.txtcurrentTime setHidden:YES];
        [self.sliderSeek setHidden:YES];
        return ;
    }
    
    /* Update the scrubber during normal playback. */
    __weak YTAudioPlayerController *weakSelf = self;
    playerTimerObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                         queue:NULL /* If you pass NULL, the main queue is used. */
                                                                    usingBlock:^(CMTime time){
                                                                        [weakSelf syncScrubber];
                                                                    }];
    //    }
}

- (void)syncScrubber{
    
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.sliderSeek.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [self.sliderSeek minimumValue];
        float maxValue = [self.sliderSeek maximumValue];
        double time = CMTimeGetSeconds([self.queuePlayer currentTime]);
        NSString *currentTime = [YTOnWorldUtility stringWithTimeInterval:time];
        [self.txtcurrentTime setText:currentTime];
        [self.sliderSeek setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (CMTime)playerItemDuration{
    
    AVPlayerItem *playerItem = [self.queuePlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - control

- (void)syncPlaybutton {
    if(self.queuePlayer.rate >0) {
        [self.btnPlay setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
    }else {
        [self.btnPlay setImage:[UIImage imageNamed:@"icon_audio_player"] forState:UIControlStateNormal];
    }
}
- (void)showStopButton {
    [self.btnPlay setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
}

- (void)showPlayButton {
    [self.btnPlay setImage:[UIImage imageNamed:@"icon_audio_player"] forState:UIControlStateNormal];
}

- (void)syncButtonPlay {
    if(self.queuePlayer.rate > 0.0) {
        [self.queuePlayer pause];
        [self.btnPlay setImage:[UIImage imageNamed:@"icon_audio_player"] forState:UIControlStateNormal];
    }else {
        [self.queuePlayer play];
        [self.btnPlay setImage:[UIImage imageNamed:@"pause_icon"] forState:UIControlStateNormal];
    }
}


- (IBAction)click_play:(id)sender {
    [self syncButtonPlay];
}

- (IBAction)click_next:(id)sender {
    if(self.queuePlayer.items.count >0){
        [self.queuePlayer advanceToNextItem];
        [self.queuePlayer play];
    }
}

- (IBAction)click_back:(id)sender {
    
}

- (IBAction)click_cloase_imagAdv:(id)sender {
    [self.advImageView setHidden:YES];
}

- (IBAction)click_skip:(id)sender {
}

- (IBAction)volumeChanged:(id)sender {
    
    if (CHROMCAST_MANAGER.chromcastCtrl.isConnected) {
        float idealVolume = self.sliderVolume.value/10.0f;
        idealVolume = MIN(1.0, MAX(0.0, idealVolume));
        
        [CHROMCAST_MANAGER.chromcastCtrl.deviceManager setVolume:idealVolume];
    }
}



#pragma mark - control audio view


- (void)setHiddenLoadingView:(BOOL)flag {
    if(flag) {
        [self.loadingView stopAnimating];
    }else {
        [self.loadingView startAnimating];
    }
    [self.loadingView setHidden:flag];
}
#pragma mark - adv 

- (void)loadAdvData {
    
    NSArray *advs = [contentObj.detail.adv allObjects];
    NSSortDescriptor *sortStart = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES];
    m_adv  = [[NSMutableArray alloc]initWithArray:[advs sortedArrayUsingDescriptors:@[sortStart]]];
    if(m_adv.count >0) {
        currentAdvObject = m_adv [0];
    }
}



- (BFTask *)parserAdvInfo{
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [[DATA_MANAGER advInfoWithURLString:currentAdvObject.link] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            [completionSource setError:task.error];
        }else {
            currnetAdvInfo = task.result;
            [completionSource setResult:nil];
        }
        return nil;
    }];
    return completionSource.task;
}


- (void)startAdv {
    
   
    if(self.queuePlayer) { // pause audio
        [self.queuePlayer pause];
    }
    if(currentAdvObject) {
        if(currentAdvObject.type.intValue == TypeVideo) {
            if(currnetAdvInfo) {
                NSURL *url = [NSURL URLWithString:currnetAdvInfo.url];
                AVPlayerItem *playItem = [[AVPlayerItem alloc] initWithURL:url];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoAdvPlayerItemDidReachEnd:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:advPlayerItem];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoAdPlayerItemFailedToReachEnd:)
                                                             name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                           object:advPlayerItem];
                
                [playItem addObserver:self forKeyPath:@"status"
                              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                              context:itemAdvContext];
                
                advPlayerItem = playItem;
                advPlayer = [[AVPlayer alloc]initWithPlayerItem:advPlayerItem];
                
                // update duration & current time
                __weak YTAudioPlayerController * weakSelf = self;
                advTimerObserver= [advPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {
                    
                    int i = (int)(currnetAdvInfo.duration - CMTimeGetSeconds(advPlayer.currentTime));
                    if (i >= 0) {
                        NSString *lbAdvSecond = [NSString stringWithFormat:@"This ad will close in %d", i];
                        [weakSelf.lbAdvTime setText:lbAdvSecond];
                    }
                    else {
                        [weakSelf.lbAdvTime setText:@""];
                    }
                }];
                [self.queuePlayer pause];
                [advPlayer play];
            }else {
                [self didFinishAdv];
            }
        }else if(currentAdvObject.type.intValue == TypeImage){
            
            [self.advImageView setHidden:NO];
            [self.imgAdv sd_setImageWithURL:[NSURL URLWithString:currnetAdvInfo.url] placeholderImage:[UIImage imageNamed:@"placeHolder.png"]];
        }
    }
}



- (void)releaseCurrentAdv {
    
    [advPlayerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:advPlayerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                  object:advPlayerItem];

    
}

- (void)didFinishAdv {
    if(m_adv.count > 0) {
        [m_adv removeObjectAtIndex:0];
        [self nextAdv];
    }
    if(self.queuePlayer) { // played
        [self.queuePlayer play];
    }else {
        [self startAudio];
    }
}

- (void)nextAdv {
    if(m_adv.count > 0) {
        currentAdvObject = m_adv[0];
    }else {
        currnetAdvInfo = nil;
        currentAdvObject = nil;
    }
}


- (void)scheduleTimerDisplayAdv {
    
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:currnetAdvInfo.start
                                             target:self
                                           selector:@selector(timerDisplayAdv:)
                                           userInfo:nil repeats:NO];
}


- (void)timerDisplayAdv:(NSTimer *)timer {
   
    if(currentAdvObject.type.intValue == TypeVideo) {
        if(self.queuePlayer) {
            [self.queuePlayer pause];
        }
    }
    [self startAdv];
}

- (void)timerAppearSkipButton:(NSTimer *)timer {
    if(isPlayingAdv) {
        _btnSkip.hidden = NO;
    }
    [timerSkip invalidate];
    timerSkip = nil;
    
}



- (void)videoAdvPlayerItemDidReachEnd:(NSNotification *)notification {
    [self didFinishAdv];
    
}

- (void)videoAdPlayerItemFailedToReachEnd:(NSNotification *)notification {
    [self didFinishAdv];

}




#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    [self _remoteControlReceivedWithEvent:receivedEvent];
}


- (void)_remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    NSLog(@"received event!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if ([self queuePlayer].rate > 0.0) {
                    [[self queuePlayer] pause];
                } else {
                    [[self queuePlayer] play];
                }
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [[self queuePlayer] play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [[self queuePlayer] pause];
                break;
            }
            default:
                break;
        }
    }
}
#pragma mark - audio session management
- (BOOL) canBecomeFirstResponder {
    return YES;
}


@end
