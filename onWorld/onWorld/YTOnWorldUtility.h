//
//  YTOnWorldUtility.h
//  OnWorld
//
//  Created by yestech1 on 6/24/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kYTServiceName = @"YTServiceName";
static NSString *kYTAccountName = @"YTAccountName";
static NSString *kYTPassword = @"kYTPassword";


@interface YTOnWorldUtility : NSObject

+ (UIColor *)getBlueColor;
+ (UIFont *)getFontWithSize:(CGFloat)size;
+ (void)showError:(NSString *)error;

+ (UIStoryboard *)appStoryboard;

+ (int)numberItemPerTableCell;

+ (int)collectionViewItemPerRow;

+ (NSTimeInterval)timeIntervalWithString:(NSString *)string;

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)totalSeconds;

+ (UIImage *)redrawUIImage:(UIImage *)image withSize:(CGSize)size;
@end
