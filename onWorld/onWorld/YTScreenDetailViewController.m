
//  YTScreenDetailViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTScreenDetailViewController.h"
#include "YTDetailViewController.h"
#import "YTRelativeViewController.h"
#import "YTTimelineViewController.h"
#import "YTDetailViewCell.h"
#import "YTPlayerViewController.h"
#import "YTAudioPlayerController.h"
#import "YTScheduleViewController.h"
#import "YTDeviceViewController.h"

@interface YTScreenDetailViewController () <YTDelegatePlayItem,YTDelegateSelectRelativeItem,YTSelectedItemProtocol,DelegateSelectedScheduleItem,ChromecastControllerDelegate>{
    NSMutableArray *viewControllers;
    YTContent *contentObj;
    UIButton *rightBarItem;

}

@end


@implementation YTScreenDetailViewController


- (id)init {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        viewControllers = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CHROMCAST_MANAGER.chromcastCtrl setDelegate:self];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    self.navigationController.navigationBar.topItem.title = @"";
    
    rightBarItem=[UIButton buttonWithType:0];
    rightBarItem.frame=CGRectMake(0,0,35,40);
    NSString *castImage = @"cast_off";
    if(CHROMCAST_MANAGER.chromcastCtrl.isConnected) {
        castImage = @"cast_on";
    }
    
    [rightBarItem addTarget:self  action:@selector(click_chromcast:)
      forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem setImage:[UIImage imageNamed:castImage]
             forState:UIControlStateNormal];
   
     rightBarItem.imageView.animationImages = @[[UIImage imageNamed:@"cast_white_on0"], [UIImage imageNamed:@"cast_white_on1"],[UIImage imageNamed:@"cast_white_on2"],[UIImage imageNamed:@"cast_white_on1"]];
    
    UIBarButtonItem *RightButton=[[UIBarButtonItem alloc] initWithCustomView:rightBarItem];
    self.navigationItem.rightBarButtonItem=RightButton;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}


- (void)didConnectToDevice:(GCKDevice *)device {
    [rightBarItem setImage:[UIImage imageNamed:@"cast_on"] forState:UIControlStateNormal];
}


- (void)didDisconnect {
    [rightBarItem setImage:[UIImage imageNamed:@"cast_off"] forState:UIControlStateNormal];
}



- (void)click_chromcast:(UIBarButtonItem *)sender {
    
    [self performSegueWithIdentifier:@"listDeviceCast" sender:self];
    
    [rightBarItem.imageView setAnimationDuration:10];
    
}

- (void)reloadViewWithContentID:(NSNumber *)contentID {
    _contentID = contentID;
    [self configureView];
}

- (void)configureView {
    
    [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:_contentID];
    BFTask *task = nil;
    if(contentObj.detail) {
        task = [BFTask taskWithResult:nil];
    }else {
        task = [DATA_MANAGER pullAndSaveContentDetail:_contentID];
    }
    [task continueWithBlock:^id(BFTask *task) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        if(contentObj.detail == nil) {
            contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:_contentID];
        }
        
        viewControllers = [NSMutableArray array];
        
        
       
        
        
        if([YTOnWorldUtility isIdiomIphone]) {
            
            YTDetailViewController *detailViewCtrl = [[YTDetailViewController alloc]initWithContent:contentObj];
            [detailViewCtrl setDelegate:self];
            [viewControllers addObject:detailViewCtrl];
            
            
            
            if(contentObj.detail.isLive.intValue == 1) {
                if(contentObj.detail.timeline.allObjects.count > 0) {
                    YTScheduleViewController *scheduleViewCtrl = [[YTScheduleViewController alloc]initWithArray:contentObj.detail.timeline.allObjects
                                                                                                       delegate:self
                                                                                                            tag:0];
                    [viewControllers addObject:scheduleViewCtrl];
                }
            }else if(contentObj.detail.timeline.count >0 || contentObj.detail.episode.allObjects.count >0){
                YTTimelineViewController *timelineCtrl = [[YTTimelineViewController alloc]initWithContent:contentObj delegate:self tableTag:0];
                [viewControllers addObject:timelineCtrl];
            }
        }else {
            
            UIViewController *viewCtrl = nil;
            if(contentObj.detail.isLive.intValue == 1) {
                if(contentObj.detail.timeline.allObjects.count > 0) {
                    viewCtrl = [[YTScheduleViewController alloc]initWithArray:contentObj.detail.timeline.allObjects
                                                                     delegate:self
                                                                          tag:0];
                }
            }else if(contentObj.detail.timeline.count >0 || contentObj.detail.episode.allObjects.count >0){
                 viewCtrl = [[YTTimelineViewController alloc]initWithContent:contentObj delegate:self tableTag:0];
            }
            YTDetailViewController *detailViewCtrl = [[YTDetailViewController alloc]initWithContent:contentObj timelineView:viewCtrl];
            [detailViewCtrl setDelegate:self];
            [viewControllers addObject:detailViewCtrl];

            
        }
        

        if(contentObj.gen){
            NSArray *relatives = contentObj.gen.content.allObjects;
            if(relatives.count >1) {
                YTRelativeViewController *relativeCtrl = [[YTRelativeViewController alloc]initWithArray:relatives
                                                                                                display:contentObj.gen.category.mode.intValue];
                [relativeCtrl setDelegate:self];
                [viewControllers addObject:relativeCtrl];
            }
        }
        [self.tableView reloadData];
        
        return nil;
    }];
}

- (void)setContentID:(NSNumber *)ID {
    _contentID = ID;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return viewControllers.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    UIViewController *viewCtrl = viewControllers[indexPath.row];

    CGRect viewFrame = viewCtrl.view.frame;
    viewFrame.size.width = self.tableView.frame.size.width;
    [cell.contentView setFrame:viewFrame];
    viewCtrl.view.frame = viewFrame;
    [cell.contentView addSubview:viewCtrl.view];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([YTOnWorldUtility isIdiomIphone]) {
        UIViewController *viewCtrl = viewControllers[indexPath.row];
        return viewCtrl.view.frame.size.height;
    }else {
        if(indexPath.row == 0) {
            return 410;
        }
       return self.tableView.frame.size.height - 410;
    }
}



#pragma mark - protocol


- (void)delegatePlayitem:(int)itemID {
    
    if(contentObj) {
        if(contentObj.detail.mode.intValue == ModeView) {
            
            YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initPlayID:contentObj.contentID episodesID:@(itemID)];
            if(playerViewCtrl) {
                UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
                [navCtrl pushViewController:playerViewCtrl animated:YES];
            }
        }else {
//            YTAudioPlayerController *musicPlayerCtrl = [[YTAudioPlayerController alloc]initWithID:playItem.contentID];
//            if(musicPlayerCtrl) {
//                UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
//                [navCtrl pushViewController:musicPlayerCtrl animated:YES];
//                
//            }
        }
    }
}

- (void)delegatePlayItemWithID:(NSNumber *)itemID {

    if(contentObj.detail.mode.intValue == ModeView) {
        
        YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initWithID:itemID];
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

- (void)playItemWithCategoryId:(NSNumber *)contentID scheduleInded:(int)schedule_index timelineIndex:(NSNumber *)timelineID {
    if(!contentObj)
        return ;
    if(contentObj.detail.mode.intValue == ModeView) {
        
        YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initWithIndexSchedule:schedule_index
                                                                                        indexTimeline:timelineID
                                                                                            contentID:contentID];
        if(playerViewCtrl) {
            UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
            [navCtrl pushViewController:playerViewCtrl animated:YES];
        }
    }
}


- (void)delegateSelectedScheduleItemWithIndexSchedule:(int)index_schedule indexTimeline:(NSNumber *)timelineID {
    
    if(contentObj.detail.mode.intValue == ModeView) {
        
        YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initWithIndexSchedule:index_schedule
                                                                                        indexTimeline:timelineID
                                                                                            contentID:contentObj.contentID];
        if(playerViewCtrl) {
            UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
            [navCtrl pushViewController:playerViewCtrl animated:YES];
        }
    }else {
        YTAudioPlayerController *musicPlayerCtrl = [[YTAudioPlayerController alloc]initWithID:contentObj.contentID];
        if(musicPlayerCtrl) {
            UINavigationController *navCtrl = (UINavigationController *)[self.revealViewController frontViewController];
            [navCtrl pushViewController:musicPlayerCtrl animated:YES];
        }
    }

}

- (void)delegateSelectedItem:(NSNumber *)itemID {
    [self reloadViewWithContentID:itemID];
}
            
@end
