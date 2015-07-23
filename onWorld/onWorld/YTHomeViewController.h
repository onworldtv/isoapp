//
//  YTCollectionView.h
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTSelectedItemProtocol.h"
@interface YTHomeViewController : UIViewController





@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnRecomemdation;
@property (weak, nonatomic) IBOutlet UIButton *btnRecent;
@property (weak, nonatomic) IBOutlet UIButton *btnPopular;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (assign,nonatomic)int mode;
@property (weak)id<YTSelectedItemProtocol>delegate;

@property (nonatomic, weak) UIViewController *selectedViewController;



- (void)setCategories:(NSDictionary *)categories;
- (id)initWithTitle:(NSString *)title;
- (IBAction)click_recommendation:(id)sender;
- (IBAction)click_recent:(id)sender;
- (IBAction)click_popular:(id)sender;


- (IBAction)click_showMore:(id)sender;
- (void)setViewControllers:(NSArray *)newViewControllers;
- (void)loadTabView;
@end
