//
//  YTGenre.h
//  OnWorld
//
//  Created by yestech1 on 7/15/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTCategory, YTContent;

@interface YTGenre : NSManagedObject

@property (nonatomic, retain) NSNumber * genID;
@property (nonatomic, retain) NSString * genName;
@property (nonatomic, retain) YTCategory *category;
@property (nonatomic, retain) NSSet *content;
@end

@interface YTGenre (CoreDataGeneratedAccessors)

- (void)addContentObject:(YTContent *)value;
- (void)removeContentObject:(YTContent *)value;
- (void)addContent:(NSSet *)values;
- (void)removeContent:(NSSet *)values;

@end
