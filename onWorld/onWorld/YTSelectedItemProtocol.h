//
//  YTSelectedItemProtocol.h
//  OnWorld
//
//  Created by yestech1 on 7/3/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YTSelectedItemProtocol <NSObject>


@optional

- (void)delegateShowDetailContentID:(NSNumber *)contentID;

- (void)delegatePlayitem:(int)itemID;

- (void)delegateShowMoreCategoryByMode:(int)mode;

- (void)delegatePlayContentId:(NSNumber *)contentID scheduleIndex:(int)schedule_index timelineID:(NSNumber *)timelineID;


- (void)showAllContentInsideGenre:(int)genreID flag:(BOOL)flag;

@end
