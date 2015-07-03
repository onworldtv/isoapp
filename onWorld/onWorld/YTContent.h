//
//  YTContent.h
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTContentDetail, YTGenre;

@interface YTContent : NSManagedObject

@property (nonatomic, retain) NSNumber * contentID;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * karaoke;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * provID;
@property (nonatomic, retain) YTGenre *gen;
@property (nonatomic, retain) YTContentDetail *detail;

@end
