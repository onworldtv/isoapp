//
//  YTNavigationBarCustom.m
//  OnWorld
//
//  Created by yestech1 on 7/20/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTNavigationBarCustom.h"

@implementation YTNavigationBarCustom


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *image = [UIImage imageNamed: @"bg_navigarbar"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    //for iOS5
    [self setBackgroundImage:[UIImage imageNamed: @"bg_navigarbar"] forBarMetrics:UIBarMetricsDefault];
}


@end
