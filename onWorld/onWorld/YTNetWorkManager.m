//
//  YTNetWorkManager.m
//  OnWorld
//
//  Created by yestech1 on 6/17/15.
//  Copyright (c) 2015 Yestech. All rights reserved.
//

#import "YTNetWorkManager.h"

static const NSString *kServerBaseURL = @"http://api.onworldtv.com";

@implementation YTNetWorkManager

static YTNetWorkManager *m_instance;

+ (YTNetWorkManager *)shareNetworkManager {
    if(!m_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            m_instance = [[YTNetWorkManager alloc]init];
        });
    }
    return m_instance;
}


- (id)init {
    self =[super init];
    if(self) {
        [self initalizeLaunchApp];
    }
    return self;
}


#pragma mark - private
- (void)setLanguage:(int)languageID {
    [[NSUserDefaults standardUserDefaults]setObject:@(languageId) forKey:@"kYTLanguageID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setUserId:(NSInteger)userid accessToken:(NSString *)token {
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setInteger:userid forKey:@"kYTUserID"];
    [userdefault setObject:token forKey:@"kYTToken"];
    [userdefault synchronize];
}

- (void)initalizeLaunchApp {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger userid = [userDefault integerForKey:@"kYTUserID"];
    NSString *token = [userDefault valueForKey:@"kYTToken"];
    
    if(userid > 0) {
        userID = userid ;
    }else {
        userID = 0;
    }
    if(token != nil && [token isEqualToString:@""]) {
        access_token = token;
    }else {
        access_token = nil;
        // notifi not login 
    }
    if([userDefault integerForKey:@"kYTLanguageID"] == 0) {
        languageId = 1;
    }else {
        languageId = [userDefault integerForKey:@"kYTLanguageID"];
    }
}

- (void)sendRequestWithServicePath:(NSString *)svcPath
                       postContent:(NSString*)requestData
                        requestMethod:(NSString *)method
                      successBlock:(SuccessBlock)sucessBlock
                      failureBlock:(FailureBlock)failureBlock {
    
    NSURL *url = [NSURL URLWithString:svcPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    if(requestData) {
        [request setHTTPBody:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        sucessBlock(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failureBlock(operation,error);
    }];
    [operation start];
    
}


#pragma mark - public


- (void)loginWithUserName:(NSString *)userName passWord:(NSString *)pass successBlock:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    
    NSString *urlPath =[NSString stringWithFormat:@"%@/login",kServerBaseURL];
    NSString *postData = [NSString stringWithFormat:@"lang_id=%ld&username=%@&password=%@",languageId, userName, pass];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:postData
                       requestMethod:@"POST"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                if(failureBlock) {
                                    failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.Login" code:errorcode userInfo:response]);
                                }else {
                                    NSLog(@"%s", __func__);
                                }
                            }else {
                                access_token = [response valueForKey:@"token"];
                                userID       = [[response valueForKey:@"user_id"] integerValue];
                                [self setUserId:userID accessToken:access_token];
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];
}


- (void)logoutWithSuccessBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"%@/logout", kServerBaseURL];
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.Logout" code:errorcode userInfo:response]);
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];
}


#pragma mark - provider
- (void)pullProvidersWithSuccessBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"%@/provider&lang_id=%ld&token=%@", kServerBaseURL,languageId,access_token];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.Pull_Provider" code:errorcode userInfo:response]);
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];

}


#pragma mark - category
- (void)pullCategoriesWithSuccessBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"%@/category&lang_id=%ld&token=%@", kServerBaseURL,languageId,access_token];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.Categories" code:errorcode userInfo:response]);
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];
    
}

- (void)pullCategoriesByProvider:(int)provID successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"%@/category&lang_id=%ld&provider_id=%d&token=%@", kServerBaseURL,languageId,provID,access_token];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.CategoriesByProvider" code:errorcode userInfo:response]);
                               
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];
    
}

#pragma mark -genre

- (void)pullGenreByProvider:(int)provID categoryID:(int)cateID
               successBlock:(SuccessBlock)successBlock
               failureBlock:(FailureBlock)failureBlock {

    NSString *urlPath = [NSString stringWithFormat:@"%@/category&lang_id=%ld&provider_id=%d&category_id=%d&token=%@", kServerBaseURL,languageId,provID,cateID,access_token];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.Genre" code:errorcode userInfo:response]);
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];

}


#pragma mark -content
- (void)contentDetail:(int)contentID
         successBlock:(SuccessBlock)successBlock
         failureBlock:(FailureBlock)failureBlock {
    NSString *urlPath = [NSString stringWithFormat:@"%@/detail/index/%d&lang_id=%ld&token=%@", kServerBaseURL,contentID,languageId,access_token];
    
    [self sendRequestWithServicePath:urlPath
                         postContent:nil
                       requestMethod:@"GET"
                        successBlock:^(AFHTTPRequestOperation *operation, id response) {
                            int errorcode =[[response valueForKey:@"error"] intValue];
                            if(errorcode == 1) {
                                failureBlock(operation,[NSError errorWithDomain:@"com.OnWorldTV.ContentDetail" code:errorcode userInfo:response]);
                            }else {
                                successBlock(operation,response);
                            }
                        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            failureBlock(operation,error);
                        }];
}




@end