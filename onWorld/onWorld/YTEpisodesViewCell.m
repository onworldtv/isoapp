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
        if(self.tag == 1) {
        
            [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
            [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"6597de"]];
        }else {
            [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
             [self setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
            [_txtContentName setTextColor:[UIColor whiteColor]];
            [_txtEpisodes setTextColor:[UIColor whiteColor]];
        }
    }else {
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        if(self.tag == 1) {
            [_txtContentName setTextColor:[UIColor whiteColor]];
            [_txtEpisodes setTextColor:[UIColor whiteColor]];
        }else {
            [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
            [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"6597de"]];
        }
    }
}

@end
