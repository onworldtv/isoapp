
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
@interface YTScreenDetailViewController () <YTDelegatePlayItem,YTDelegateSelectRelativeItem,YTSelectedItemProtocol,DelegateSelectedScheduleItem>{
    NSMutableArray *viewControllers;
    YTContent *contentObj;
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
    
//    [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
     NSLog(@"%s",__FUNCTION__);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    self.navigationController.navigationBar.topItem.title = @"";
    
    UIButton *rightBarItem=[UIButton buttonWithType:0];
    rightBarItem.frame=CGRectMake(0,0,35,40);
    
    [rightBarItem addTarget:self  action:@selector(click_chromcast:)
      forControlEvents:UIControlEventTouchUpInside];
    [rightBarItem setImage:[UIImage imageNamed:@"icon_chromcast"]
             forState:UIControlStateNormal];
    UIBarButtonItem *RightButton=[[UIBarButtonItem alloc] initWithCustomView:rightBarItem];
    self.navigationItem.rightBarButtonItem=RightButton;
    
}


- (void)click_chromcast:(UIBarButtonItem *)sender {
    
    YTDeviceViewController *deviceViewCtrl = [[YTDeviceViewController alloc]init];
    deviceViewCtrl.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:deviceViewCtrl animated:YES completion:nil];
    
}


- (void)setContentID:(NSNumber *)ID {
    
    [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
     viewControllers = [NSMutableArray array];
    _contentID = ID;
    contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:ID];
    BFTask *task = nil;
    if(contentObj.detail) {
        task = [BFTask taskWithResult:nil];
    }else {
        task = [DATA_MANAGER pullAndSaveContentDetail:_contentID];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        if(contentObj.detail == nil) {
            contentObj = [YTContent MR_findFirstByAttribute:@"contentID" withValue:_contentID];
        }
        YTDetailViewController *detailViewCtrl = [[YTDetailViewController alloc]initWithContent:contentObj];
        [detailViewCtrl setDelegate:self];
        [viewControllers addObject:detailViewCtrl];
        
        if(contentObj.detail.timeline.allObjects.count >0 || contentObj.detail.episode.allObjects.count >0) {
            if(contentObj.detail.type.intValue == TypeSingle && contentObj.detail.isLive.intValue == 1 && contentObj.gen.category.cateID.intValue == 4) {
                YTScheduleViewController *scheduleViewCtrl = [[YTScheduleViewController alloc]initWithArray:contentObj.detail.timeline.allObjects
                                                                                                   delegate:self];
                [viewControllers addObject:scheduleViewCtrl];
            }else {
                YTTimelineViewController *timelineCtrl = [[YTTimelineViewController alloc]initWithContent:contentObj];
                [viewControllers addObject:timelineCtrl];
            }
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
        [DejalBezelActivityView removeViewAnimated:YES];
        return nil;
    }];
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
     UIViewController *viewCtrl = viewControllers[indexPath.row];
    return viewCtrl.view.frame.size.height;
}



#pragma mark - protocol

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

- (void)delegateSelectedScheduleItemWithIndexSchedule:(int)index_schedule indexTimeline:(int)index_timeline {
    
    if(contentObj.detail.mode.intValue == ModeView) {
        
        YTPlayerViewController *playerViewCtrl = [[YTPlayerViewController alloc]initWithIndexSchedule:index_schedule
                                                                                        indexTimeline:index_timeline
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
    [self setContentID:itemID];
}
            
@end
