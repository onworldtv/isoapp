//
//  YTCollectionView.h
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTHomeViewController : UIViewController





@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnRecomemdation;
@property (weak, nonatomic) IBOutlet UIButton *btnRecent;
@property (weak, nonatomic) IBOutlet UIButton *btnPopular;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *tabView;

@property (nonatomic, weak) UIViewController *selectedViewController;
- (IBAction)click_recommendation:(id)sender;
- (IBAction)click_recent:(id)sender;
- (IBAction)click_popular:(id)sender;


- (void)setViewControllers:(NSArray *)newViewControllers;
- (void)parentDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (void)loadTabView;
@end
