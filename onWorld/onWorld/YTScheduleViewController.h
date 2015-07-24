//
//  YTScheduleViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DelegateSelectedScheduleItem <NSObject>

- (void)delegateSelectedScheduleItemWithIndexSchedule:(int)index_schedule indexTimeline:(int)index_timeline;

@end
@interface YTScheduleViewController : UIViewController
@property (weak,nonatomic)IBOutlet UITableView *tableView;
@property (weak,nonatomic)IBOutlet UIView *topView;
@property (weak,nonatomic)IBOutlet UIView *backEndView;
- (id)initWithArray:(NSArray *)array delegate:(id<DelegateSelectedScheduleItem>)delegate;
@end
