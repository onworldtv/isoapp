//
//  YTCategory.h
//  OnWorld
//
//  Created by yestech1 on 7/6/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTContent, YTGenre;

@interface YTCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * cateID;
@property (nonatomic, retain) NSNumber * karaoke;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *genre;
@end

@interface YTCategory (CoreDataGeneratedAccessors)

- (void)addGenreObject:(YTGenre *)value;
- (void)removeGenreObject:(YTGenre *)value;
- (void)addGenre:(NSSet *)values;
- (void)removeGenre:(NSSet *)values;


@end
