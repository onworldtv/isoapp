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
@interface YTContentDetailViewController ()
{
    
    YTDetailViewController *detailViewCtrl;
    YTTimelineViewController *timelineViewCtrl;
    YTRelativeViewController *relativeViewCtrl;
}
@end

@implementation YTContentDetailViewController


-(id) init {
    self = [super initWithNibName:@"YTContentDetailViewController" bundle:nil];
    if(self) {
        detailViewCtrl = [[YTDetailViewController alloc]init];
        timelineViewCtrl = [[YTTimelineViewController alloc]init];
        relativeViewCtrl = [[YTRelativeViewController alloc]init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewController];
    
    // Do any additional setup after loading the view.
}


- (void)setContentID:(int)contentID {
    
    _contentID = contentID;
    [self initViewController];
}


- (void)initViewController {
    if(_contentID > 0) {
        
        [DejalBezelActivityView activityViewForView:self.view withLabel:nil];
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
            detailViewCtrl.view.frame = _topView.bounds;
            timelineViewCtrl.view.frame = _middleView.bounds;
            relativeViewCtrl.view.frame = _bottomView.bounds;
            [relativeViewCtrl setDelegate:self];
           
            [relativeViewCtrl setItems:relatives];
            [timelineViewCtrl setContentID:_contentID];
            [detailViewCtrl setContentID:_contentID];
            
            [detailViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_topView addSubview:detailViewCtrl.view];
            
            [timelineViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_middleView addSubview:timelineViewCtrl.view];
            
            [relativeViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_bottomView addSubview:relativeViewCtrl.view];

            [DejalBezelActivityView removeViewAnimated:YES];
            
            return nil;
        }];

    }
}

- (void)didSelectItemWithCategoryID:(int)contentID {
    [self setContentID:contentID];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
