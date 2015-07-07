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
#import "YTMainDetailViewController.h"
#import "YTTableViewController.h"


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
            [self resetHeightForScrollView];
        }else {
            
        }
        return nil;
    }];

}

- (void)initalizeHomeView{

    YTGridViewController *recommendationViewCtrl = [[YTGridViewController alloc]initWithIdentify:@"recommend" numberItem:2];
    [recommendationViewCtrl setDelegate:self];
    YTGridViewController *recentAddViewCtrl = [[YTGridViewController alloc]initWithIdentify:@"added" numberItem:2];
    [recentAddViewCtrl setDelegate:self];
    YTGridViewController *popularViewCtrl = [[YTGridViewController alloc]initWithIdentify:@"popular" numberItem:2];
    [popularViewCtrl setDelegate:self];
    
    NSArray *viewControllers = @[recommendationViewCtrl, recentAddViewCtrl, popularViewCtrl];
    
    CGRect frame = _scrollView.frame;
    
    
    videoViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's view today"];
    [videoViewCtrl setViewControllers:viewControllers];
    [videoViewCtrl setDelegate:self];
    
    videoViewCtrl.view.frame =CGRectMake(frame.origin.x, frame.origin.y, CGRectGetWidth(frame), 630);
    [videoViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    
    
    YTGridViewController *audioRecomemdation = [[YTGridViewController alloc]initWithIdentify:@"recommend" numberItem:2];
    [audioRecomemdation setDelegate:self];
    YTGridViewController *audioRecent = [[YTGridViewController alloc]initWithIdentify:@"added" numberItem:2];
    [audioRecent setDelegate:self];
    YTGridViewController *audioPopular = [[YTGridViewController alloc]initWithIdentify:@"popular" numberItem:2];
    [audioPopular setDelegate:self];
    
    
    audioViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's listen today"];
    [audioViewCtrl setViewControllers:@[audioRecomemdation,audioRecent,audioPopular]];
    [audioViewCtrl setDelegate:self];
    
    
    audioViewCtrl.view.frame=CGRectMake(frame.origin.x,635,CGRectGetWidth(frame),630);
    
    [audioViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [_scrollView setContentSize:CGSizeMake(frame.size.width,630 * 2 + 5)];
    
    [_scrollView addSubview:videoViewCtrl.view];
    [_scrollView addSubview:audioViewCtrl.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetHeightForScrollView {
    
    YTGridViewController *currentViewCtrl = (YTGridViewController*)videoViewCtrl.selectedViewController;
    CGSize size = currentViewCtrl.collectionViewLayout.collectionViewContentSize;
    CGRect videoFrame = videoViewCtrl.view.frame;
    videoFrame.size.height = size.height + 80;
    [videoViewCtrl.view setFrame:videoFrame];
    
    
    YTGridViewController *currentAudioCtrl = (YTGridViewController*)audioViewCtrl.selectedViewController;
    CGSize audiosize = currentAudioCtrl.collectionViewLayout.collectionViewContentSize;
    CGRect audioFrame = currentAudioCtrl.view.frame;
    audioFrame.size.height = audiosize.height + 80;
    audioFrame.origin.y = videoFrame.size.height + 5;
    
    [audioViewCtrl.view setFrame:audioFrame];
    
    CGSize scrollviewSize = CGSizeMake(_scrollView.frame.size.width, audioFrame.size.height + videoFrame.size.height + 5);
    [_scrollView setContentSize:scrollviewSize];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [videoViewCtrl parentDidRotateFromInterfaceOrientation:fromInterfaceOrientation numberItem:2];
    [audioViewCtrl parentDidRotateFromInterfaceOrientation:fromInterfaceOrientation numberItem:3];
    [self resetHeightForScrollView];
}


- (void)didSelectItemWithCategoryID:(int)contentID {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    
    YTMainDetailViewController *detailViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    [detailViewCtrl setContentID:contentID];
    UINavigationController *navigationController = (UINavigationController*) [self.revealViewController frontViewController];
    [navigationController pushViewController:detailViewCtrl animated:YES];
}


- (void)didClickedShowMoreCategory:(int)categoryID {
    
    NSArray *categories = nil;
    if(categoryID == -1) { // show all category
        categories = [YTCategory MR_findAll];
    }else {
        categories = [YTCategory MR_findByAttribute:@"cateId" withValue:@(categoryID)];
    }
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (YTCategory *catgory in categories) {
        NSArray *genries = [[catgory genre]allObjects];
        if(genries.count > 0) {
            for (YTGenre *genre in genries) {
                NSDictionary *genreDict = @{@"id": genre.genID, @"name": genre.genName};
                NSMutableArray *subItems = [NSMutableArray array];
                
                NSArray *contents = [[genre content]allObjects];
                for (YTContent *content in contents) {
                    
                    NSDictionary *contentDict = @{@"id":content.contentID,
                                                  @"name":content.name,
                                                  @"image":content.image,@"desc":content.desc,
                                                  @"category":catgory.name};
                    
                    [subItems addObject:contentDict];
                }
                if(subItems.count > 0) {
                    NSDictionary *object = @{@"gen":genreDict, @"content":subItems};
                    [items addObject:object];
                }
            }
        }
    }
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    YTTableViewController *moreViewController  = [[YTTableViewController alloc]initWithStyle:UITableViewStylePlain withArray:items numberItem:2];
    UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
    [navCtrll pushViewController:moreViewController animated:YES];

}


@end
