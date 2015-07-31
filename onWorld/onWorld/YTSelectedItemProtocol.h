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
- (void)didSelectItemWithCategoryID:(NSNumber *)contentID;

- (void)delegatePlayitem:(int)itemID;
- (void)delegateDisplayMoreCategoryMode:(int)mode;

- (void)playItemWithCategoryId:(NSNumber *)contentID scheduleInded:(int)schedule_index timelineIndex:(int)timeline_index;

- (void)didSelectCategory:(int)categoryID;

@end
