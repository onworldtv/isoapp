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
                                            YTCategory *category = [YTCategory MR_findFirstByAttribute:@"cateID" withValue:@(cateID) inContext:localContext];
                                            YTGenre *genre = [YTGenre MR_findFirstByAttribute:@"genID" withValue:@([[item valueForKey:@"id"] intValue]) inContext:localContext];
                                            if(genre == nil) {
                                                genre = [YTGenre MR_createEntityInContext:localContext];
                                            }
                                            genre.genID = @([[item valueForKey:@"id"] intValue]);
                                            genre.genName = [item valueForKey:@"name"];
                                            if(category){
                                               [category addGenreObject:genre];
                                            }
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


- (BFTask *)contentItemsHomeView {
    
     BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [NETWORK_MANAGER contentItemsHomeWithSuccessBlock:^(AFHTTPRequestOperation *operation, id response) {
        [completionSource setResult:response];
        
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [completionSource setError:error];
    }];
    return completionSource.task;
}

- (BFTask *)pullGroupContent {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSArray *categories = [YTCategory MR_findAll];
    
    if(categories.count > 0) {
        BFTask *task = [BFTask taskWithResult:nil];
        for (YTCategory *category in categories) {
            NSArray *gens = [category.genre allObjects];
            for (YTGenre *gen in gens) {
                task = [task continueWithBlock:^id(BFTask *task) {
                    return [self pullContentByCate:category.cateID.intValue genre:gen.genID.intValue];
                }];
            }
        }
    }else {
        [completionSource setResult:nil];
    }
    return completionSource.task;
}

- (BFTask *)pullContentByCate:(int)cateID genre:(int)genID {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    [NETWORK_MANAGER getContentByCategory:cateID genre:genID
                             successBlock:^(AFHTTPRequestOperation *operation, id response) {
                                 
                                 NSArray *groups = [response valueForKey:@"groups"];
                                 NSDictionary *dictItem = groups[0];
                                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                     
                                     for (NSDictionary *dictionary in [dictItem valueForKey:@"items"]) {
                                      
                                         YTGenre *genre = [YTGenre MR_findFirstByAttribute:@"genID" withValue:@(genID) inContext:localContext];
                                         int contentID = [[dictionary valueForKey:@"id"] intValue];
                                         YTContent *content = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID) inContext:localContext];
                                         if(!content) {
                                             content = [YTContent MR_createEntityInContext:localContext];
                                         }
                                         content.contentID = @(contentID);
                                         content.name = [dictionary valueForKey:@"name"];
                                         content.desc = [dictionary valueForKey:@"description"];
                                         content.image = [dictionary valueForKey:@"image"];
                                         content.karaoke = @([[dictionary valueForKey:@"karaoke"] intValue]);
                                         [genre addContentObject:content];
                                        
                                         /*
                                          id	:	242
                                          name	:	Mundo Television Channel
                                          description	:
                                          image	:	http://img.onworldtv.com/wxh//banner/2015/05/25/409711-200515_mundotv_logo.jpg
                                          karaoke	:
                                          @property (nonatomic, retain) NSNumber * contentID;
                                          @property (nonatomic, retain) NSString * desc;
                                          @property (nonatomic, retain) NSString * image;
                                          @property (nonatomic, retain) NSNumber * karaoke;
                                          @property (nonatomic, retain) NSString * name;
                                          @property (nonatomic, retain) NSNumber * status;
                                          @property (nonatomic, retain) NSNumber * provID;
                                          */
                                         
                                         
                                     }
                                 } completion:^(BOOL contextDidSave, NSError *error) {
                                     if(error)
                                        [completionSource setError:error];
                                     else
                                         [completionSource setResult:nil];
                                 }];
                                
                                 
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    return completionSource.task;
}
@end
