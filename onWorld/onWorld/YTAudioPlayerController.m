//
//  YTAudioPlayerController.m
//  OnWorld
//
//  Created by yestech1 on 7/16/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTAudioPlayerController.h"

static void *itemRateContext = &itemRateContext;
static void *itemStatusContext = &itemStatusContext;
static void *itemCurrentContext = &itemCurrentContext;
static void *itemkeepUpContext = &itemkeepUpContext;
static void *itemBufferEmptyContext = &itemBufferEmptyContext;

@interface YTAudioPlayerController (){
    int contentID;
    id timerObserver;
    YTContent *contentObj;
    YTDetail *detail;
    id playerTimerObserver;
    float mRestoreAfterScrubbingRate;
    BOOL isSeeking;
}

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;
@end

@implementation YTAudioPlayerController

- (id)initWithID:(int)ID {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        contentID = ID;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigarbar"] forBarMetrics:UIBarMetricsDefault];
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    
    [self sharedSession]; // set app run backgroud
    
    BFTask *task = nil;
    
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID)];
    if(contentObj) {
        task =[BFTask taskWithResult:nil];
    }else {
        task = [[DATA_MANAGER pullAndSaveContentDetail:contentID] continueWithBlock:^id(BFTask *task) {
            contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID)];
            return nil;
        }];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        
        [self startAudio];
        return nil;
    }];

    
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


- (void)startAudio {
    
    if(contentObj) {
        [DejalBezelActivityView activityViewForView:self.view withLabel:nil];
        NSURL *url = [NSURL URLWithString:@"http://origin.onworldtv.com:1935/adstream/ITV.Home.Shopping.Ad.720p.mp4/playlist.m3u8"];
//        NSURL *url = [NSURL URLWithString:contentObj.detail.link];
        
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
        
        [adPlayerItem addObserver:self forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          context:itemStatusContext];
        
        __weak UIImageView *imageView = self.imageView;
        [[DLImageLoader sharedInstance]loadImageFromUrl:contentObj.image completed:^(NSError *error, UIImage *image) {
            
            [imageView setImage:image];
        }];
    }else {
        [self didFinishAudioPlayerItem];
    }
}

- (void)audioPlayerDidFinish:(NSNotification*)notification {
    [self didFinishAudioPlayerItem];
}

- (void)audioLoadPlayerFailured:(NSNotification *)notification {
    [self didFinishAudioPlayerItem];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == itemStatusContext) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusFailed: {
                [self didFinishAudioPlayerItem];
                NSLog(@"AVPlayerItemStatusFailed");
            }
            
            break;
            case AVPlayerItemStatusReadyToPlay:{
                [DejalBezelActivityView removeViewAnimated:YES];
                [self.queuePlayer play];
                [self initScrubberTimer];
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                isSeeking = NO;
            }
            break;
            default:
                break;
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)removePlayerTimeObserver
{
    if (playerTimerObserver)
    {
        [self.queuePlayer removeTimeObserver:playerTimerObserver];
        playerTimerObserver = nil;
    }
}

- (IBAction)beginScrubbing:(id)sender
{
    mRestoreAfterScrubbingRate = [self.queuePlayer rate];
    [self.queuePlayer setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}
- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.f;
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]] && !isSeeking)
    {
        isSeeking = YES;
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [self.queuePlayer seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    if (!playerTimerObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.sliderSeek bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak YTAudioPlayerController *weakSelf = self;
            playerTimerObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                                   ^(CMTime time)
                                   {
                                       [weakSelf syncScrubber];
                                   }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [self.queuePlayer setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}




- (void)didFinishAudioPlayerItem {
   
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [self removePlayerTimeObserver];
    
    if(self.queuePlayer) {
        [self.queuePlayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    if(self.queuePlayer.items.count > 0) {
        [self.queuePlayer advanceToNextItem];
    }else {
        
    }
    [self.queuePlayer seekToTime:kCMTimeZero];
    [self.sliderSeek setValue:0.0];
    [self.txtcurrentTime setText:@"00:00:00"];
    [self syncScrubber];
    [self syncButtonPlay];
}




-(void)initScrubberTimer{
//    if(detail.isLive.intValue == 0) {
        double interval = .1f;
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.sliderSeek bounds]);
            interval = 0.5f * duration / width;
            NSString *txtInterVal = [YTOnWorldUtility stringWithTimeInterval:duration];
            [self.txtDuration setText:txtInterVal];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    [self.queuePlayer removeAllItems];
    [self.queuePlayer pause];
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



- (void)syncButtonPlay {
    if(self.queuePlayer.rate >0.0) {
        [self.queuePlayer pause];
        [self.btnPlay setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }else {
        [self.queuePlayer play];
        [self.btnPlay setImage:[UIImage imageNamed:@"icon_audio_player"] forState:UIControlStateNormal];
    }
}


- (IBAction)click_play:(id)sender {
    [self syncButtonPlay];
    if(self.queuePlayer.rate == 0 && _sliderSeek.value == 0.0){
        [self startAudio];
    }
    
}

- (IBAction)click_next:(id)sender {
    if(self.queuePlayer.items.count >0){
        [self.queuePlayer advanceToNextItem];
        [self.queuePlayer play];
    }
}

- (IBAction)click_back:(id)sender {
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
