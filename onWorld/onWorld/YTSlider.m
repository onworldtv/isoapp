//
//  YTSlider.m
//  OnWorld
//
//  Created by yestech1 on 7/10/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTSlider.h"

@implementation YTSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame: (CGRect)rect{
    if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,35)])){
        [self awakeFromNib];
    }
    return self;
}
@end
