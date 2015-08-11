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

//    if(selected) {
//        if(self.tag == 1) {
//            
//            [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
//            [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"6597de"]];
//        }else {
//            [self.contentView setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
//            [self setBackgroundColor:[UIColor colorWithHexString:@"6597de"]];
//            [_txtContentName setTextColor:[UIColor whiteColor]];
//            [_txtEpisodes setTextColor:[UIColor whiteColor]];
//        }
//    }else {
//        [self.contentView setBackgroundColor:[UIColor clearColor]];
//        [self setBackgroundColor:[UIColor clearColor]];
//        if(self.tag == 1) {
//            [_txtContentName setTextColor:[UIColor whiteColor]];
//            [_txtEpisodes setTextColor:[UIColor whiteColor]];
//        }else {
//            [_txtContentName setTextColor:[UIColor colorWithHexString:@"6597de"]];
//            [_txtEpisodes setTextColor:[UIColor colorWithHexString:@"6597de"]];
//        }
//    }

    
    if(selected) {
        if(self.tag == 1) { //for player
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
       
    }else {
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        if(self.tag == 1) {
            [_txtContentName setTextColor:[UIColor whiteColor]];
            [_txtSinger setTextColor:[UIColor whiteColor]];
            [_txtTimeline setTextColor:[UIColor whiteColor]];
        }else {
            [_txtContentName setTextColor:[UIColor colorWithHexString:@"#4D4D4D"]];
            [_txtSinger setTextColor:[UIColor colorWithHexString:@"#4D4D4D"]];
            [_txtTimeline setTextColor:[UIColor colorWithHexString:@"#8A8A8A"]];
        }
    }
}

@end
