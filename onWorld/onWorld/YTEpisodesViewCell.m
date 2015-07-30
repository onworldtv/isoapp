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

    if(selected) {
        [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
        [_txtContentName setTextColor:[UIColor whiteColor]];
        [_txtEpisodes setTextColor:[UIColor whiteColor]];
    }else {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"4D4D4D"]];
        [_txtContentName setTextColor:[UIColor colorWithHexString:@"8A8A8A"]];
    }

}

@end
