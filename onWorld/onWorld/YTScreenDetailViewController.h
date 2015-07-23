//
//  YTScreenDetailViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTScreenDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak,nonatomic)IBOutlet UITableView *tableView;
@property (assign,nonatomic) NSNumber * contentID;
@end
