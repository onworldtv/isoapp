//
//  YTChromcastDeviceViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTDeviceViewController : UIViewController <ChromecastControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
