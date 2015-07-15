//
//  YTProvider.h
//  OnWorld
//
//  Created by yestech1 on 7/15/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YTProvider : NSManagedObject

@property (nonatomic, retain) NSNumber * provID;
@property (nonatomic, retain) NSString * provName;

@end
