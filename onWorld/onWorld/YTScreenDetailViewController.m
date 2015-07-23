//
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
@interface YTScreenDetailViewController () <YTDelegatePlayItem,YTDelegateSelectRelativeItem>{
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
   
   
    // Do any additional setup after loading the view from its nib.
}



- (void)setContentID:(NSNumber *)ID {
    
     NSLog(@"%s",__FUNCTION__);
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
            YTTimelineViewController *timelineCtrl = [[YTTimelineViewController alloc]init];
            [viewControllers addObject:timelineCtrl];
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
    
    YTDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
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


- (void)delegateSelectedItem:(NSNumber *)itemID {
    [self setContentID:itemID];
}
@end
