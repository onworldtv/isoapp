//
//  YTSearchViewCell.m
//  OnWorld
//
//  Created by yestech1 on 7/7/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTSearchViewCell.h"

@implementation YTSearchViewCell


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"YTSideViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UITableViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
