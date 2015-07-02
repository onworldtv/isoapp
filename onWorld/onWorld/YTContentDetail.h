//
//  YTContentDetail.h
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTContent;

@interface YTContentDetail : NSManagedObject

@property (nonatomic, retain) NSString * contDescription;
@property (nonatomic, retain) NSNumber * contID;
@property (nonatomic, retain) NSString * contLink;
@property (nonatomic, retain) NSString * contName;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * episodes;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * imdb;
@property (nonatomic, retain) NSNumber * langID;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) YTContent *content;

@end
