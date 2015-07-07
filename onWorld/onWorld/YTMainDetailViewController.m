//
//  YTMainDetailViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/3/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTMainDetailViewController.h"
#import "YTContentDetailViewController.h"
@interface YTMainDetailViewController ()
{
    
    YTContentDetailViewController * mainViewCtrl;
}
@end

@implementation YTMainDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    mainViewCtrl = [[YTContentDetailViewController alloc]init];
    [self.m_scrollView setContentSize:CGSizeMake(self.m_scrollView.frame.size.width, mainViewCtrl.view.frame.size.height)];
    [mainViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.m_scrollView addSubview:mainViewCtrl.view];
    
    if(_contentID) {
        [mainViewCtrl setContentID:_contentID];
    }

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setContentID:(int)categoryID {
    _contentID = categoryID;
    if(mainViewCtrl) {
        [mainViewCtrl setContentID:categoryID];
    }
}



@end
