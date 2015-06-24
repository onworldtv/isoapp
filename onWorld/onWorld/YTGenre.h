//
//  YTGenre.h
//  OnWorld
//
//  Created by yestech1 on 6/24/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YTGenre : NSManagedObject

@property (nonatomic, retain) NSNumber * genID;
@property (nonatomic, retain) NSNumber * cateID;

@property (nonatomic, retain) NSString * genName;

@end
