//
//  YTAdv.h
//  OnWorld
//
//  Created by yestech1 on 7/15/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTDetail;

@interface YTAdv : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * skip;
@property (nonatomic, retain) NSNumber * skipeTime;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) YTDetail *detail;

@end
