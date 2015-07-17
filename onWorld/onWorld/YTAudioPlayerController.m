//
//  YTAudioPlayerController.m
//  OnWorld
//
//  Created by yestech1 on 7/16/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTAudioPlayerController.h"
#import "YTMusicPlayer.h"

@interface YTAudioPlayerController (){
    int contentID;
    id timerObserver;
    YTContent *contentObj;
    YTDetail *detail;
    id playerTimerObserver;
}
@property (strong, nonatomic) YTMusicPlayer *musicPlayer;
@end

@implementation YTAudioPlayerController

- (id)initWithID:(int)ID {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        [YTMusicPlayer sharedSession];
        self.musicPlayer = [[YTMusicPlayer alloc]init];
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
        [self startMusicPlayer];
        return nil;
    }];
    
    
}


- (void)startMusicPlayer {
    [self.musicPlayer playWithUrlPath:contentObj.detail.link
                            songTitle:contentObj.name
                           singerName:detail.actor.name];
    __weak UIImageView *imageView = self.imageView;
    [[DLImageLoader sharedInstance]loadImageFromUrl:contentObj.image completed:^(NSError *error, UIImage *image) {
        imageView.contentMode = UIViewContentModeCenter;
        if (imageView.bounds.size.width > image.size.width && imageView.bounds.size.height > image.size.height) {
            imageView.contentMode = UIViewContentModeScaleToFill;
        }
        [imageView setImage:image];
    }];
    [self initScrubberTimer];
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
            CGFloat width = CGRectGetWidth([self.sliderSeek bounds]);
            interval = 0.5f * duration / width;
            NSString *txtInterVal = [YTOnWorldUtility stringWithTimeInterval:duration];
            [self.txtDuration setText:txtInterVal];
        }
        
        /* Update the scrubber during normal playback. */
//        __weak YTAudioPlayerController *weakSelf = self;
        
       playerTimerObserver = [self.musicPlayer.avQueuePlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                        queue:NULL /* If you pass NULL, the main queue is used. */
                                                                   usingBlock:^(CMTime time){
                                                                       NSLog(@"sjhfjkshfklshfjklsh");
                                                                   }];
    }
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
        double time = CMTimeGetSeconds([self.musicPlayer.avQueuePlayer currentTime]);
        NSString *currentTime = [YTOnWorldUtility stringWithTimeInterval:time];
        [self.txtcurrentTime setText:currentTime];
        [self.sliderSeek setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (CMTime)playerItemDuration{
    
    AVPlayerItem *playerItem = [self.musicPlayer.avQueuePlayer currentItem];
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
    [self.musicPlayer clear];
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)click_play:(id)sender {
    
    if(self.musicPlayer) {
        if(self.musicPlayer.avQueuePlayer.rate > 0.0) {
            [self.musicPlayer pause];
            //update
        }else {
            [self.musicPlayer play];
        }
    }
}

- (IBAction)click_next:(id)sender {
}

- (IBAction)click_back:(id)sender {
}

#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    [self.musicPlayer remoteControlReceivedWithEvent:receivedEvent];
}

#pragma mark - audio session management
- (BOOL) canBecomeFirstResponder {
    return YES;
}


@end
