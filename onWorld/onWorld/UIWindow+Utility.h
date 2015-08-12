//
//  UIWindow+Utility.h
//  OnWorld
//
//  Created by yestech1 on 8/12/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Utility)


- (UIViewController *)visibleViewController;

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc ;
@end
