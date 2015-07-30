//
//  YTDataManager.h
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTAdvInfo.h"
#define DATA_MANAGER  ([YTDataManager sharedDataManager])


@interface YTDataManager : NSObject
@property (strong,nonatomic)NSDictionary *homeData;

+ (YTDataManager *)sharedDataManager;

- (BFTask *)getProvider;

- (BFTask *)getAllGenreByCateID:(int)cateID;

- (BFTask *)getGenres;

- (BFTask *)pullAllMetaData;

- (BFTask *)contentItemsHomeView;

- (BFTask *)pullGroupContent;

- (BFTask *)getAllCatatgoryByMode:(int)mode;

- (BFTask *)pullAndSaveContentDetail:(NSNumber*)contentID;

- (BFTask *)getContentsByProviderId:(NSNumber *)providerID;

- (BFTask *)getGroupGenreByCategory:(NSNumber *)cateID;
    
- (BFTask *)advInfoWithURLString:(NSString *)urlPath;

@end
