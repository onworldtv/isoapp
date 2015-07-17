//
//  YTContentDetailViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTContentDetailViewController.h"
#import "YTDetailViewController.h"
#import "YTRelativeViewController.h"
#import "YTTimelineViewController.h"
#import "YTPlayerViewController.h"
#import "YTAudioPlayerController.h"
@interface YTContentDetailViewController ()
{
    
    YTDetailViewController *detailViewCtrl;
    YTTimelineViewController *timelineViewCtrl;
    YTRelativeViewController *relativeViewCtrl;
}
@end

@implementation YTContentDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    [self initViewController];
}


- (void)setContentID:(int)contentID {
    
    _contentID = contentID;
    [self initViewController];
}


- (void)initViewController {
    
    if(_contentID > 0) {
        [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
        BFTask *task = nil;
        YTContent *contentItem = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(_contentID)];
        if(contentItem.detail) {
            task = [BFTask taskWithResult:nil];
        }else {
            task = [DATA_MANAGER pullAndSaveContentDetail:_contentID];
        }
        
        [task continueWithBlock:^id(BFTask *task) {
            
            YTContent *contentItem = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(_contentID)];
            YTGenre *ralative = [YTGenre MR_findFirstByAttribute:@"genID" withValue:contentItem.gen.genID];
            NSMutableArray *relatives = [NSMutableArray array];
            for (YTContent *content in [ralative.content allObjects]) {
                [relatives addObject:@{@"id":content.contentID,
                                       @"name":content.name,
                                       @"image":content.image}];
            }
            
            detailViewCtrl = [[YTDetailViewController alloc]init];
            timelineViewCtrl = [[YTTimelineViewController alloc]init];
            relativeViewCtrl = [[YTRelativeViewController alloc]init];
            [relativeViewCtrl setMode:[contentItem.gen.category.mode intValue]];
            
            detailViewCtrl.view.frame = CGRectMake(0, 0, _scrollView.frame.size.width, 435);
            [detailViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
            [_scrollView addSubview:detailViewCtrl.view];

            if([contentItem.detail.timeline allObjects].count > 0 || contentItem.detail.episode.allObjects.count > 0) {
                timelineViewCtrl.view.frame = CGRectMake(0, detailViewCtrl.view.frame.size.height, _scrollView.frame.size.width, 310);
                [timelineViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
                [_scrollView addSubview:timelineViewCtrl.view];
            }else {
                 timelineViewCtrl.view.frame = CGRectMake(0, detailViewCtrl.view.frame.size.height, _scrollView.frame.size.width, 0);
            }
            relativeViewCtrl.view.frame = CGRectMake(0,
                                                     detailViewCtrl.view.frame.size.height + timelineViewCtrl.view.frame.size.height
                                                     , _scrollView.frame.size.width,
                                                     410);
            [detailViewCtrl setDelegate:self];
            [relativeViewCtrl setDelegate:self];
            [relativeViewCtrl setItems:relatives];
            [timelineViewCtrl setContentID:_contentID];
            [detailViewCtrl setContentID:_contentID];
            
            [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, timelineViewCtrl.view.frame.size.height + detailViewCtrl.view.frame.size.height + relativeViewCtrl.view.frame.size.height)];
            
            
            
            
            [relativeViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
            [_scrollView addSubview:relativeViewCtrl.view];

            [DejalBezelActivityView removeViewAnimated:YES];
            
            return nil;
        }];
        
        
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    detailViewCtrl.view.frame = CGRectMake(0, 0, _scrollView.frame.size.width, 435);
    if(timelineViewCtrl.view.frame.size.height != 0)
        timelineViewCtrl.view.frame = CGRectMake(0, detailViewCtrl.view.frame.size.height, _scrollView.frame.size.width, 310);
    relativeViewCtrl.view.frame = CGRectMake(0,
                                             detailViewCtrl.view.frame.size.height + timelineViewCtrl.view.frame.size.height
                                             , _scrollView.frame.size.width,
                                             410);
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, timelineViewCtrl.view.frame.size.height + detailViewCtrl.view.frame.size.height + relativeViewCtrl.view.frame.size.height)];
}

- (void)didSelectItemWithCategoryID:(int)contentID {
    
    [UIView animateWithDuration:0.5 animations:^{
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    }];
    [self setContentID:contentID];
    
}

- (void)delegatePlayitem:(int)itemID {
    if(itemID >0) {
        
        YTContent *content = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(itemID)];
        if(content.detail.mode.intValue == ModeView) {
        
            YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initWithNibName:@"YTPlayerViewController" bundle:nil itemID:itemID];
            if(playerViewCtrl) {
                UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
                [navCtrl pushViewController:playerViewCtrl animated:YES];
            }
        }else {
            YTAudioPlayerController *musicPlayerCtrl = [[YTAudioPlayerController alloc]initWithID:itemID];
            if(musicPlayerCtrl) {
                UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
                [navCtrl pushViewController:musicPlayerCtrl animated:YES];
            }
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
