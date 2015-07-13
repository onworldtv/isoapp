////
////  YTAdvViewController.m
////  OnWorld
////
////  Created by yestech1 on 7/13/15.
////  Copyright (c) 2015 OnWorld. All rights reserved.
////
//
//#import "YTAdvViewController.h"
//
////static void *YTPlayerAdPlayerItemStatusObservationContext = &YTPlayerAdPlayerItemStatusObservationContext;
//
//
//@interface YTAdvViewController ()
//{
//    NSArray *advObjects;
//    YTAdvInfo *currentAdv;
//    NSDictionary *currentAdvObject;
//    
//    NSMutableArray *queueAdvs;
//
//    
//    
//    AVPlayer *advPlayer;
//    AVPlayerItem *advPlayerItem;
//}
//@end
//
//@implementation YTAdvViewController
//
//
//- (id)init {
//    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
//    if(self) {
//        
//    }
//    return self;
//}
//
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // Do any additional setup after loading the view from its nib.
//}
//
//
//- (void)loadAdvView {
//    FileType type = [[currentAdvObject valueForKey:@"type"] intValue];
//    if(type == TypeVideo) {
//        [self.advImageView setHidden:YES];
//        int skip = [[currentAdvObject valueForKey:@"skip"] intValue];
//        
//    }
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//- (BFTask *)loadAdvInfoWithUrl:(YTAdv *)adv {
//    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    [[DATA_MANAGER advInfoWithURLString:adv.link] continueWithBlock:^id(BFTask *task) {
//        if(task.error) {
//            YTAdvInfo * advInfo = (YTAdvInfo *)task.result;
//            advInfo.start = adv.start.intValue;
//            advInfo.duration = adv.duration.intValue;
//            advInfo.skip = adv.skip.intValue;
//            advInfo.skipTime = adv.skip.intValue;
//            advInfo.type = adv.type.intValue;
//            [queueAdvs addObject:advInfo];
//            [completionSource setResult:nil];
//        }else {
//            [completionSource setError:task.error];
//        }
//        return nil;
//    }];
//    return completionSource.task;
//}
//- (BFTask *)loadAdvInformation {
//    
//    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    BFTask *task = [BFTask taskWithResult:nil];
//    YTContent * content = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@""];
//    for(YTAdv *adv in content.detail.adv.allObjects) {
//        task = [task continueWithBlock:^id(BFTask *task) {
//            return [self loadAdvInfoWithUrl:[adv valueForKey:@"link"]];
//        }];
//    }
//    [task continueWithBlock:^id(BFTask *task) {
//        [completionSource setResult:nil];
//        return nil;
//    }];
//    return completionSource.task;
//}
//
//- (void)playAdvVideo {
//    NSURL *url = [NSURL URLWithString:@"http://origin.onworldtv.com:1935/adstream/ITV.Home.Shopping.Ad.720p.mp4/playlist.m3u8"];
//    
//    AVPlayerItem *adPlayerItem = [[AVPlayerItem alloc] initWithURL:url];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(videoAdvPlayerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:adPlayerItem];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(videoAdPlayerItemFailedToReachEnd:)
//                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
//                                               object:adPlayerItem];
//    
////    [adPlayerItem addObserver:self forKeyPath:kStatusKey
////                      options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
////                      context:YTPlayerAdPlayerItemStatusObservationContext];
//    
//    advPlayerItem = adPlayerItem;
//    
//    advPlayer = [[AVPlayer alloc]initWithPlayerItem:advPlayerItem];
//    
//    
//    // update duration & current time
//    __weak YTAdvViewController * weakSelf = self;
//    [advPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {
//        
////        int i = (int)(currentAdv.duration.intValue - CMTimeGetSeconds(advPlayer.currentTime));
////        NSLog(@"play at duration :%d",i);
////        if (i >= 0) {
////            NSString *lbAdvSecond = [NSString stringWithFormat:@"This ad will close in %d", i];
////            [weakSelf.txtLableAdv setText:lbAdvSecond];
////        }
////        else {
////            [weakSelf.txtL setText:@""];
////            
////        }
//    }];
//    [advPlayer play];
//
//}
//
//
//- (void)videoAdvPlayerItemDidReachEnd:(NSNotification *)notification {
//    
//}
//
//- (void)videoAdPlayerItemFailedToReachEnd:(NSNotification *)notification {
//    
//}
//
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
//- (IBAction)click_skip:(id)sender {
//}
//- (IBAction)click_closeAdd:(id)sender {
//}
//@end
