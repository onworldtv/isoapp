//
//  YTOnWorldUtility.m
//  OnWorld
//
//  Created by yestech1 on 6/24/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTOnWorldUtility.h"

@implementation YTOnWorldUtility



+ (UIColor *)getBlueColor
{
    return [UIColor colorWithRed:94.0f/255.0f green:162.0f/255.0f blue:253.0f/255.0f alpha:1.0f];
}


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

+ (UIStoryboard *)appStoryboard {
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *backWindow = application.windows[0];
    UIStoryboard *storyboard = backWindow.rootViewController.storyboard;
    return storyboard;
}


+ (int)collectionViewItemPerRow {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 2;
    }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 4;
    }
    return 2;
}

+ (CGSize)collectionViewCellSizeByWidth:(int)width{
    int delta = width % [self collectionViewItemPerRow];
    if(delta == 0) {
        return CGSizeMake(width / [self collectionViewItemPerRow], HEIGHT_COLLECTION_ITEM);
    }else {
        
    }
    
    return CGSizeZero;
}

+ (NSTimeInterval)timeIntervalWithString:(NSString *)string
{
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSInteger milliseconds = 0;
    
    if (! [scanner scanInteger:&hours]) {
        return NAN;
    }
    
    if (! [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] intoString:nil]) {
        return NAN;
    }
    
    if (! [scanner scanInteger:&minutes]) {
        return NAN;
    }
    
    if (! [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] intoString:nil]) {
        return NAN;
    }
    
    if (! [scanner scanInteger:&seconds]) {
        return NAN;
    }
    
    if ([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."] intoString:nil]) {
        [scanner scanInteger:&milliseconds];
    }
    
    return hours * 60 * 60 + minutes * 60 + seconds + (CGFloat)milliseconds / 1000.f;
}

+ (NSString *)stringWithTimeInterval:(NSTimeInterval)totalSeconds
{
    NSInteger hours = totalSeconds / (60 * 60);
    NSInteger minutes = (totalSeconds - hours * 60 * 60) / 60;
    CGFloat seconds = MAX(0, (totalSeconds - hours * 60 * 60 - minutes * 60));
    return [NSString stringWithFormat:@"%02li:%02li:%06.3f", (long)hours, (long)minutes, seconds];
}

@end
