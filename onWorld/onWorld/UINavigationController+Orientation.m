//
//  UINavigationController+Orientation.m
//  OnWorld
//
//  Created by yestech1 on 8/6/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)


- (NSUInteger)supportedInterfaceOrientations {
    return [self.visibleViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {

    return true;
}
@end
