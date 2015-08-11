//
//  YTScheduleViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DelegateSelectedScheduleItem <NSObject>

- (void)delegateSelectedScheduleItemWithIndexSchedule:(int)index_schedule indexTimeline:(NSNumber *)timelineID;

@end
@interface YTScheduleViewController : UIViewController
@property (weak,nonatomic)IBOutlet UITableView *tableView;
@property (weak,nonatomic)IBOutlet UIView *topView;
@property (weak,nonatomic)IBOutlet UIView *titleView;
@property (weak,nonatomic)IBOutlet UIView *backEndView;
@property (weak,nonatomic)IBOutlet NSLayoutConstraint *heightContraint;
- (id)initWithArray:(NSArray *)array delegate:(id<DelegateSelectedScheduleItem>)delegate tag:(NSInteger)tagView;

@end
