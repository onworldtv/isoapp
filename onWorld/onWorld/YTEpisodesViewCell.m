//
//  YTEpisodesViewCell.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTEpisodesViewCell.h"

@implementation YTEpisodesViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    if([self.superview.superview isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.superview.superview;
        if(tableView.tag == 0)
            return ;
    }
    if(selected) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"6597de"]];
    }else {
        [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtContentName setTextColor:[UIColor whiteColor]];
        [_txtEpisodes setTextColor:[UIColor whiteColor]];
    }
    
}

@end
