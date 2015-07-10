//
//  YTTimelineViewCell.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTTimelineViewCell.h"

@implementation YTTimelineViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(selected) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtSinger setTextColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtTimeline setTextColor:[UIColor colorWithHexString:@"6597de"]];
    }else {
        [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtContentName setTextColor:[UIColor whiteColor]];
        [_txtSinger setTextColor:[UIColor whiteColor]];
        [_txtTimeline setTextColor:[UIColor whiteColor]];
    }

    // Configure the view for the selected state
}

@end
