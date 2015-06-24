//
//  YTOnWorldUtility.m
//  OnWorld
//
//  Created by yestech1 on 6/24/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTOnWorldUtility.h"

@implementation YTOnWorldUtility





+ (UIFont *)getFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"UTM BEBAS" size:size];
}

+ (void)showError:(NSString *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
        [alert show];
    }
}

@end
