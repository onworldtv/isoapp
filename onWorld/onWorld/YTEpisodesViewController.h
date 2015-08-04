//
//  YTEpisodesViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTEpisodesViewController : UITableViewController
@property (retain,nonatomic)NSMutableArray *contentItems;
@property (assign,nonatomic)int cellViewTag;
- (id)initWithContent:(NSArray *)array detailID:(NSNumber *)detailID delegate:(id<YTSelectedItemProtocol>)delegate;
@end
