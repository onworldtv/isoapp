//
//  YTTableHeaderCell.h
//  OnWorld
//
//  Created by yestech1 on 6/30/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTTableHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;

- (IBAction)click_more:(id)sender;
@end
