//
//  YTDataManager.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTDataManager.h"

@implementation YTDataManager


static YTDataManager *m_instance;
+ (YTDataManager *)sharedDataManager {
    
    if(!m_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            m_instance = [[YTDataManager alloc]init];
        });
    }
    return m_instance;
}


- (id)init {
    self = [super init];
    if(self) {
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"OnWorld.sqlite"];
        NSLog(@"%@", [[NSPersistentStore MR_urlForStoreName:[MagicalRecord defaultStoreName]] path]);
    }
    return self;
}

- (BFTask *)getProvider {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [NETWORK_MANAGER pullProvidersWithSuccessBlock:^(AFHTTPRequestOperation *operation, id response) {
        NSDictionary *items = [response valueForKey:@"items"];
        if(items.count > 0) {
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                
                if(![YTProvider MR_findFirstByAttribute:@"provID" withValue:@(-1) inContext:localContext]) {
                    YTProvider *allProvider = [YTProvider MR_createEntityInContext:localContext];
                    allProvider.provID = @(-1);
                    allProvider.provName = @"ALL";
                }
                for(NSDictionary *item in items) {
                    YTProvider *provider = [YTProvider MR_findFirstByAttribute:@"provID"
                                                                     withValue:@([[item valueForKey:@"id"] intValue])
                                                                     inContext:localContext];
                    if(provider == nil) {
                        provider = [YTProvider MR_createEntityInContext:localContext];
 
                    }
                    provider.provID = @([[item valueForKey:@"id"] intValue]);
                    provider.provName = [item valueForKey:@"name"];
                }
            }];
        }
        [completionSource setResult:nil];
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [completionSource setError:error];
    }];
    return completionSource.task;
}



- (BFTask *)getCategories {
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [NETWORK_MANAGER pullCategoriesWithSuccessBlock:^(AFHTTPRequestOperation *operation, id response) {
        NSDictionary *items = [response valueForKey:@"items"];
        if(items.count > 0) {
            
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                for(NSDictionary *item in items) {
                    YTCategory *category = [YTCategory MR_findFirstByAttribute:@"cateID" withValue: @([[item valueForKey:@"id"] intValue]) inContext:localContext];
                    if(category == nil) {
                        category = [YTCategory MR_createEntityInContext:localContext];
                    }
                    category.cateID = @([[item valueForKey:@"id"] intValue]);
                    category.name = [item valueForKey:@"name"];
                    category.mode = @([[item valueForKey:@"mode"] intValue]);
                    category.karaoke =@([[item valueForKey:@"karaoke"]intValue]);
                }
            }];
        }
        [completionSource setResult:nil];
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [completionSource setError:error];
    }];
    return completionSource.task;
}

- (BFTask *)getAllGenreByCateID:(int)cateID{
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [NETWORK_MANAGER pullGenreByCategory:cateID
                            successBlock:^(AFHTTPRequestOperation *operation, id response) {
                                NSDictionary *items = [response valueForKey:@"items"];
                                if(items.count > 0) {
                                    
                                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                        for(NSDictionary *item in items) {
                                            YTGenre *genre = [YTGenre MR_findFirstByAttribute:@"genID" withValue:@([[item valueForKey:@"id"] intValue]) inContext:localContext];
                                            if(genre == nil) {
                                                genre = [YTGenre MR_createEntityInContext:localContext];
                                            }
                                            genre.genID = @([[item valueForKey:@"id"] intValue]);
                                            genre.cateID = @(cateID);
                                            genre.genName = [item valueForKey:@"name"];
                                        }
                                    } completion:^(BOOL contextDidSave, NSError *error) {
                                        if(error == nil)
                                            [completionSource setResult:nil];
                                        else
                                            [completionSource setError:error];
                                    }];
                                }
                                
                            } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [completionSource setError:error];
                            }];
    return completionSource.task;
}

- (BFTask *)getGenres {
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSArray * categories =[YTCategory MR_findAll];
    NSMutableArray *tasks = [NSMutableArray array];
    if(categories.count > 0) {
        for (YTCategory *category in categories) {
           [tasks addObject:[self getAllGenreByCateID:category.cateID.intValue]];
        }
        [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
            if(task.error == nil){
                [completionSource setResult:nil];
            }else {
                [completionSource setError:task.error];
            }
            return nil;
        }];
        
    }else {
        [completionSource setResult:nil];
    }
    return completionSource.task;
}


- (BFTask *)pullCategoriesAndGenre {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[self getCategories] continueWithBlock:^id(BFTask *task) {
        if(task.error == nil) {
           [[self getGenres] continueWithBlock:^id(BFTask *task) {
               if(task.error == nil) {
                   [completionSource setResult:nil];
               }else {
                   [completionSource setError:task.error];
               }
               return nil;
           }];
        }else {
            return task;
        }
        return nil;
    }];
   
    return completionSource.task;
}

- (BFTask *)pullAllMetaData {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableArray *tasks = [NSMutableArray array];
    [tasks addObject:[self getProvider]];
    [tasks addObject:[self pullCategoriesAndGenre]];
    [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        if(task.error == nil) {
            [completionSource setResult:nil];
        }else{
            [completionSource setError:task.error];
        }
        return nil;
    }];
    return completionSource.task;
}


@end
