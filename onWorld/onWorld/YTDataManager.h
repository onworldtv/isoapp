//
//  YTDataManager.h
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATA_MANAGER  ([YTDataManager sharedDataManager])



@interface YTDataManager : NSObject


+ (YTDataManager *)sharedDataManager;

- (BFTask *)getProvider;

- (BFTask *)getAllGenreByCateID:(int)cateID;

- (BFTask *)getGenres;

- (BFTask *)pullAllMetaData;

- (BFTask *)contentItemsHomeView;

- (BFTask *)pullGroupContent;

@end
