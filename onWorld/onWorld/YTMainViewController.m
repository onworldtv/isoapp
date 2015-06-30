//
//  YTMainViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTMainViewController.h"
#import "SWRevealViewController.h"
#import "YTHomeViewController.h"
#import "YTGridViewController.h"
@interface YTMainViewController ()
{
    YTHomeViewController *videoViewCtrl;
    YTHomeViewController *audioViewCtrl;
}
@end

@implementation YTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }
    
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.title = nil;
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-2000, -2000) forBarMetrics:UIBarMetricsDefault];
    
    [self initalizeHomeView];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:nil];
    [[DATA_MANAGER contentItemsHomeView]continueWithBlock:^id(BFTask *task) {
        [DejalBezelActivityView removeViewAnimated:YES];
        if(task.error == nil) {
            NSDictionary* contentItems = task.result;
            if(videoViewCtrl) {
                [videoViewCtrl setCategories:[contentItems valueForKey:@"view"]];
            }
            if(audioViewCtrl){
                [audioViewCtrl setCategories:[contentItems valueForKey:@"listen"]];
            }
        }else {
            
        }
        return nil;
    }];

}

- (void)initalizeHomeView{

    YTGridViewController *listViewController1 = [[YTGridViewController alloc]initWithIdentify:@"recommend" numberItem:2];
    YTGridViewController *listViewController2 = [[YTGridViewController alloc]initWithIdentify:@"added" numberItem:2];
    YTGridViewController *listViewController3 = [[YTGridViewController alloc]initWithIdentify:@"popular" numberItem:2];
    
    NSArray *viewControllers = @[listViewController1, listViewController2, listViewController3];
    
    CGRect frame = _scrollView.frame;
    
    
    videoViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's view today"];
    [videoViewCtrl setViewControllers:viewControllers];
    
    videoViewCtrl.view.frame =CGRectMake(frame.origin.x, frame.origin.y, CGRectGetWidth(frame), 630);
    [videoViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    
    
    YTGridViewController *l1 = [[YTGridViewController alloc]initWithIdentify:@"recommend" numberItem:2];
    YTGridViewController *l2 = [[YTGridViewController alloc]initWithIdentify:@"added" numberItem:2];
    YTGridViewController *l3 = [[YTGridViewController alloc]initWithIdentify:@"popular" numberItem:2];
    
    
    audioViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's listen today"];
    [audioViewCtrl setViewControllers:@[l1,l2,l3]];
    audioViewCtrl.view.frame=CGRectMake(frame.origin.x,630,CGRectGetWidth(frame),630);
    
    [audioViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [_scrollView setContentSize:CGSizeMake(frame.size.width,630*2)];
    
    [_scrollView addSubview:videoViewCtrl.view];
    [_scrollView addSubview:audioViewCtrl.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [videoViewCtrl parentDidRotateFromInterfaceOrientation:fromInterfaceOrientation numberItem:2];
    
    YTGridViewController *currentViewCtrl = (YTGridViewController*)videoViewCtrl.selectedViewController;
    CGSize size = currentViewCtrl.collectionViewLayout.collectionViewContentSize;
    CGRect videoFrame = videoViewCtrl.view.frame;
    videoFrame.size.height = size.height + 80;
    [videoViewCtrl.view setFrame:videoFrame];
    
    
    [audioViewCtrl parentDidRotateFromInterfaceOrientation:fromInterfaceOrientation numberItem:3];
    YTGridViewController *currentAudioCtrl = (YTGridViewController*)audioViewCtrl.selectedViewController;
    CGSize audiosize = currentAudioCtrl.collectionViewLayout.collectionViewContentSize;
    CGRect audioFrame = currentAudioCtrl.view.frame;
    audioFrame.size.height = audiosize.height + 80;
    audioFrame.origin.y = videoFrame.size.height;
    
    [audioViewCtrl.view setFrame:audioFrame];
    
    CGSize scrollviewSize = CGSizeMake(_scrollView.frame.size.width, audioFrame.size.height + videoFrame.size.height);
    [_scrollView setContentSize:scrollviewSize];
    
    
}

@end
