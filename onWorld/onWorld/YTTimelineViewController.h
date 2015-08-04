//
//  YTTimelineViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTTimelineViewController : UIViewController
@property (assign,nonatomic)int contentID;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeLine;
@property (weak, nonatomic) IBOutlet UIButton *btnEpisodes;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIView *tabViewContainer;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) int  tag;
- (void)setViewControllers:(NSArray *)newViewControllers;

- (id)initWithContent:(YTContent*)content delegate:(id<YTSelectedItemProtocol>)delegate;





@end
