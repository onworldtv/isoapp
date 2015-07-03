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
    
    detailViewCtrl.view.frame = _topView.bounds;
    [detailViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_topView addSubview:detailViewCtrl.view];

    timelineViewCtrl.view.frame = _middleView.bounds;
    [timelineViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_middleView addSubview:timelineViewCtrl.view];
    
    relativeViewCtrl.view.frame = _bottomView.bounds;
    [relativeViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_bottomView addSubview:relativeViewCtrl.view];
    
    
    
    
    
    // Do any additional setup after loading the view.
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
