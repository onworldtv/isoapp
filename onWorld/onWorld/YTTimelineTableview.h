//
//  YTTimelineTableview.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTTimelineTableview : UITableViewController

@property (retain,nonatomic)NSMutableArray *contentItems;


- (id)initWithContent:(NSArray *)array;
@end
