//
//  YTDetail.h
//  OnWorld
//
//  Created by yestech1 on 8/12/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTActor, YTAdv, YTCountry, YTDirector, YTEpisodes, YTTag, YTTimeline;

@interface YTDetail : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * imdb;
@property (nonatomic, retain) NSNumber * isLive;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * link_mp3;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSNumber * package;
@property (nonatomic, retain) NSNumber * permission;
@property (nonatomic, retain) NSNumber * providerID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSDate * today;
@property (nonatomic, retain) YTActor *actor;
@property (nonatomic, retain) NSSet *adv;
@property (nonatomic, retain) YTCountry *country;
@property (nonatomic, retain) YTDirector *diretory;
@property (nonatomic, retain) NSSet *episode;
@property (nonatomic, retain) YTTag *tag;
@property (nonatomic, retain) NSSet *timeline;
@end

@interface YTDetail (CoreDataGeneratedAccessors)

- (void)addAdvObject:(YTAdv *)value;
- (void)removeAdvObject:(YTAdv *)value;
- (void)addAdv:(NSSet *)values;
- (void)removeAdv:(NSSet *)values;

- (void)addEpisodeObject:(YTEpisodes *)value;
- (void)removeEpisodeObject:(YTEpisodes *)value;
- (void)addEpisode:(NSSet *)values;
- (void)removeEpisode:(NSSet *)values;

- (void)addTimelineObject:(YTTimeline *)value;
- (void)removeTimelineObject:(YTTimeline *)value;
- (void)addTimeline:(NSSet *)values;
- (void)removeTimeline:(NSSet *)values;

@end
