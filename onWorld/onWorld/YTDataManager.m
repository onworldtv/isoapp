//
//  YTDataManager.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTDataManager.h"

@implementation YTDataManager


static YTDataManager *m_instance;
+ (YTDataManager *)sharedDataManager {
    
    if(!m_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            m_instance = [[YTDataManager alloc]init];
        });
    }
    return m_instance;
}


- (id)init {
    self = [super init];
    if(self) {
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"OnWorld.sqlite"];
    }
    return self;
}
@end
