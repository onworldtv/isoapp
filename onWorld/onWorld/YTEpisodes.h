//
//  YTEpisodes.h
//  OnWorld
//
//  Created by yestech1 on 8/12/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTDetail;

@interface YTEpisodes : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * episodesID;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * advs;
@property (nonatomic, retain) YTDetail *detail;

@end
