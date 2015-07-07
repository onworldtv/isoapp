//
//  YTCountry.h
//  OnWorld
//
//  Created by yestech1 on 7/6/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YTCountry : NSManagedObject

@property (nonatomic, retain) NSNumber * countryID;
@property (nonatomic, retain) NSString * name;

@end
