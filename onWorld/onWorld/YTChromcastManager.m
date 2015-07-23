//
//  YTChromcast.m
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTChromcastManager.h"

@implementation YTChromcastManager


static YTChromcastManager* m_instance;

+ (YTChromcastManager *)sharedChromcastManager {
    if(!m_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            m_instance = [[YTChromcastManager alloc]init];
        });
    }
    return m_instance;
}

- (id)init {
    self = [super init];
    if(self) {
        _chromcastCtrl = [[ChromecastDeviceController alloc]init];
        [_chromcastCtrl performScan:YES];
    }
    return self;
}


@end
