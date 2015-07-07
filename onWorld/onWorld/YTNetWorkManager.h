//
//  YTNetWorkManager.h
//  OnWorld
//
//  Created by yestech1 on 6/17/15.
//  Copyright (c) 2015 Yestech. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^SuccessBlock)(AFHTTPRequestOperation *operation,id response);
typedef void (^FailureBlock)(AFHTTPRequestOperation *operation,NSError*error);

#define NETWORK_MANAGER ([YTNetWorkManager  shareNetworkManager])

@interface YTNetWorkManager : NSObject {
    
    NSString          *access_token;
    NSInteger         languageId;
    NSInteger         userID;
    NSString          *m_userName;
    BOOL                loginStatus;
}



+ (YTNetWorkManager *)shareNetworkManager;


- (BOOL)isLogin;

- (void)clearData;

- (void)loginWithUserName:(NSString *)userName
                 passWord:(NSString *)pass
             successBlock:(SuccessBlock)successBlock
                  failure:(FailureBlock)failureBlock;


- (void)logoutWithSuccessBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;


- (void)pullProvidersWithSuccessBlock:(SuccessBlock) successBlock
                         failureBlock:(FailureBlock)failureBlock;


- (void)pullCategoriesWithSuccessBlock:(SuccessBlock)successBlock
                          failureBlock:(FailureBlock)failureBlock;


- (void)pullCategoriesByProvider:(int)provID
                    successBlock:(SuccessBlock)successBlock
                    failureBlock:(FailureBlock)failureBlock;


- (void)pullGenreByProvider:(int)provID categoryID:(int)cateID
                    successBlock:(SuccessBlock)successBlock
                    failureBlock:(FailureBlock)failureBlock;



- (void)pullGenreByCategory:(int)cateID  successBlock:(SuccessBlock)successBlock
               failureBlock:(FailureBlock)failureBlock;

- (void)contentDetail:(int)contentID
               successBlock:(SuccessBlock)successBlock
               failureBlock:(FailureBlock)failureBlock;



- (void)getContentByCategory:(int)contentID genre:(int)genID
         successBlock:(SuccessBlock)successBlock
         failureBlock:(FailureBlock)failureBlock;

- (void)contentItemsHomeWithSuccessBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
@end
