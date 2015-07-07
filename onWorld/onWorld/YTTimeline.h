//
//  YTTimeline.h
//  OnWorld
//
//  Created by yestech1 on 7/6/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YTTimeline : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;

@end
