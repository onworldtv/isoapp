//
//  YTChromcast.h
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChromecastDeviceController.h"
#define CHROMCAST_MANAGER ([YTChromcastManager  sharedChromcastManager])
@interface YTChromcastManager : NSObject
@property (retain,nonatomic)ChromecastDeviceController *chromcastCtrl;

+ (YTChromcastManager*)sharedChromcastManager;


@end
