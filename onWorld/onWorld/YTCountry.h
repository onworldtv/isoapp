//
//  YTCountry.h
//  OnWorld
//
//  Created by yestech1 on 7/15/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTDetail;

@interface YTCountry : NSManagedObject

@property (nonatomic, retain) NSNumber * countryID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) YTDetail *detail;

@end
