//
//  YTTimeline.h
//  OnWorld
//
//  Created by yestech1 on 7/15/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTDetail;

@interface YTTimeline : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * arrayTimeline;
@property (nonatomic, retain) YTDetail *detail;

@end
