//
//  YTDataManager.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTDataManager.h"
#import "YTAdvInfo.h"
#import "XMLDictionary.h"
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
                                        YTCategory *category = [YTCategory MR_findFirstByAttribute:@"cateID"
                                                                                         withValue:@(cateID)
                                                                                         inContext:localContext];
//                                        NSLog(@"Category: %@, gen :%@",category.name,response);
                                        for(NSDictionary *item in items) {
                                            
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
    [NETWORK_MANAGER getHomeContentWithSuccessBlock:^(AFHTTPRequestOperation *operation, id response) {
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
                                 
                                 NSArray *items = [response valueForKey:@"items"];
                                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                     
                                     YTGenre *genre = [YTGenre MR_findFirstByAttribute:@"genID" withValue:@(genID) inContext:localContext];
                                     
                                     for (NSDictionary *dictionary in items) {
                                      
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

- (NSArray *)getGroupGenreByCategory:(int)cateID providerID:(int)provID {
    
    /*
     [{"gen":{"id":int,"nam":nsstring},
       "content":{"id":int, "name":nsstring}
     },
     { .......}
     ]
     */
    NSArray *categories = [YTCategory MR_findByAttribute:@"cateID" withValue:@(cateID)];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (YTCategory *catgory in categories) {
        NSArray *genries = [[catgory genre]allObjects];
        if(genries.count > 0) {
            for (YTGenre *genre in genries) {
                NSDictionary *genreDict = @{@"id": genre.genID, @"name": genre.genName,@"mode":catgory.mode};
                NSMutableArray *subItems = [NSMutableArray array];
                
                NSArray *contents = [[genre content]allObjects];
                for (YTContent *content in contents) {
                    
                    NSDictionary *contentDict = @{@"id":content.contentID,
                                                  @"name":content.name,
                                                  @"image":content.image,@"desc":content.desc,
                                                  @"category":catgory.name};
                    
                    [subItems addObject:contentDict];
                }
                if(subItems.count > 0) {
                    NSDictionary *object = @{@"title":genreDict, @"content":subItems};
                    [items addObject:object];
                }
            }
        }
    }
    return items;
}

- (BFTask *)pullAndSaveContentDetail:(int)contentID {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];

    [NETWORK_MANAGER contentDetail:contentID
                      successBlock:^(AFHTTPRequestOperation *operation, id response) {
                          [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                              YTContent *contentItem = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(contentID) inContext:localContext];
                             
                              YTDetail *detail = nil;
                              if(contentItem.detail == nil) {
                                  detail = [YTDetail MR_createEntityInContext:localContext];
                              }else {
                                  detail = contentItem.detail;
                              }
                              detail.link = [response valueForKeyPath:@"content.link"];
                              detail.year = @([[response valueForKeyPath:@"content.year"] intValue]);
                              detail.duration = @([[response valueForKeyPath:@"content.duration"] intValue]);
                              detail.link_mp3 = [response valueForKeyPath:@"content.link_mp3"];
                              detail.rating = @([[response valueForKeyPath:@"content.rating"] intValue]);
                              detail.imdb = @([[response valueForKeyPath:@"content.imdb"] intValue]);
                              detail.mode = @([[response valueForKeyPath:@"content.mode"] intValue]);
                              detail.type = @([[response valueForKeyPath:@"content.type"] intValue]);
                              detail.episodes = @([[response valueForKeyPath:@"content.episodes"] intValue]);
                              detail.isLive = @([[response valueForKeyPath:@"content.isLive"] intValue]);
                              detail.package = @([[response valueForKeyPath:@"content.package_type"] intValue]);
                              detail.permission = @([[response valueForKeyPath:@"permission"] intValue]);
                              detail.providerID = @([[response valueForKeyPath:@"content.pro_id"] intValue]);
                              
                              if([response valueForKeyPath:@"timelines"]) {
                                  NSArray *timelines = [response valueForKey:@"timelines"];
                                  for (NSDictionary *timeline in timelines) {
                                      YTTimeline *timelineObject = [YTTimeline MR_findFirstByAttribute:@"name" withValue:[timeline valueForKeyPath:@"name"] inContext:localContext];
                                      if(!timelineObject) {
                                          timelineObject = [YTTimeline MR_createEntityInContext:localContext];
                                      }
                                      timelineObject.name = [timeline valueForKeyPath:@"name"];
                                      timelineObject.image = [timeline valueForKeyPath:@"image"];
                                      timelineObject.desc = [timeline valueForKeyPath:@"description"];
                                      timelineObject.link = [timeline valueForKeyPath:@"link"];
                                      timelineObject.start = @([[timeline valueForKeyPath:@"start"] floatValue]);
                                      timelineObject.end = @([[timeline valueForKeyPath:@"end"] floatValue]);
                                      
                                      [detail addTimelineObject:timelineObject];
                                  }
                                  
                              }
                              
                              
                              if([response valueForKeyPath:@"episodes"]) {
                                  NSArray *epiArr = [response valueForKey:@"episodes"];
                                  for (NSDictionary *episo in epiArr) {
                                      YTEpisodes *episodes = [YTEpisodes MR_findFirstByAttribute:@"episodesID"
                                                                                       withValue: @([[episo valueForKeyPath:@"id"] intValue])
                                                                                       inContext:localContext];
                                      if(!episodes) {
                                          episodes = [YTEpisodes MR_createEntityInContext:localContext];
                                      }
                                      episodes.name = [episo valueForKeyPath:@"name"];
                                      episodes.image = [episo valueForKeyPath:@"image"];
                                      episodes.desc = [episo valueForKeyPath:@"description"];
                                      episodes.episodesID = @([[episo valueForKeyPath:@"id"] intValue]);
                                      
                                      [detail addEpisodeObject:episodes];
                                  }
                                  
                              }
                              
                              if([response valueForKeyPath:@"countries"]) {
                                  NSArray *countries = [response valueForKey:@"countries"];
                                  for (NSDictionary *countryDic in countries) {
                                      YTCountry * country = [YTCountry MR_findFirstByAttribute:@"countryID"
                                                                                     withValue: @([[countryDic valueForKeyPath:@"id"] intValue])
                                                                                     inContext:localContext];
                                      if(!country) {
                                          country = [YTCountry MR_createEntityInContext:localContext];
                                          country.countryID = @([[countryDic valueForKeyPath:@"id"] intValue]);
                                          country.name = [countryDic valueForKeyPath:@"name"];
                                      }
                                      [detail setCountry:country];
                                  }
                                  
                              }
                              if([response valueForKeyPath:@"adv"]) {
                                  NSArray *advs = [response valueForKey:@"adv"];
                                  if(detail.adv.count > 0) {
                                      for (YTAdv *adv in detail.adv.allObjects) {
                                          [adv MR_deleteEntityInContext:localContext];
                                      }
                                  }
                                  for (NSDictionary *advDict in advs) {
                                      YTAdv * adv = [YTAdv MR_createEntityInContext:localContext];
                                      adv.link = [advDict valueForKey:@"link"];
                                      adv.start = @([[advDict valueForKey:@"start"] intValue]);
                                      adv.duration = @([[advDict valueForKey:@"duration"]intValue]);
                                      adv.skip = @([[advDict valueForKey:@"skip"]intValue]);
                                      adv.skipeTime = @([[advDict valueForKey:@"skippable_time"]intValue]);
                                      if([[advDict valueForKey:@"type"] isEqualToString:@"video"]) {
                                          adv.type = @(TypeVideo);
                                      }else {
                                          adv.type = @(TypeImage);
                                      }
                                      [detail addAdvObject:adv];
                                  }
                              }
                              
                              if(detail) {
                                  [contentItem setDetail:detail];
                              }
                              
                          } completion:^(BOOL contextDidSave, NSError *error) {
                              [completionSource setResult:nil];
                          }];
                          
                      } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                          [completionSource setError:error];
                      }];
    
    return completionSource.task;
}


- (BFTask *)advInfoWithURLString:(NSString *)urlPath {
    BFTaskCompletionSource *completionSource =[BFTaskCompletionSource taskCompletionSource];
    
    [NETWORK_MANAGER getAdvWithUrl:urlPath successBlock:^(AFHTTPRequestOperation *operation, id response) {
        NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLData:response];
        NSString *title = [xmlDict valueForKeyPath:@"Ad.InLine.AdTitle"];
        NSDictionary *videoAdv = [xmlDict valueForKeyPath:@"Ad.InLine.Video"];
        YTAdvInfo *advInformation = [[YTAdvInfo alloc]init];
        if(videoAdv) {
            NSString *clickLink = [videoAdv valueForKeyPath:@"VideoClicks.ClickThrough.URL.__text"];
            NSString *advLink = [videoAdv valueForKeyPath:@"MediaFiles.MediaFile.URL"];
            advInformation.title = title;
            advInformation.duration = [YTOnWorldUtility timeIntervalWithString:[videoAdv valueForKey:@"Duration"]];
            advInformation.touchLink = clickLink;
            advInformation.url = advLink;
        }else {
            NSDictionary *imageDict = [xmlDict valueForKeyPath:@"Ad.InLine.NonLinearAds"];
            advInformation.title = title;
            advInformation.touchLink = [imageDict valueForKeyPath:@"NonLinear.NonLinearClickThrough.URL"];
            advInformation.url = [imageDict valueForKeyPath:@"NonLinear.URL"];
        }
        [completionSource setResult:advInformation];
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [completionSource setError:error];
    }];
    
    /*[NETWORK_MANAGER getAdvWithUrl:urlPath successBlock:^(AFHTTPRequestOperation *operation, id response) {
        NSError *error = nil;
        DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:response options:0 error:&error];
        if (error) {
            NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
            [completionSource setError:error];
            return;
        }
        DDXMLElement *rootElement = [document rootElement];
        DDXMLElement *adElement = [[rootElement elementsForName:@"Ad"] firstObject];
        DDXMLElement *contentElement = (DDXMLElement *)[adElement childAtIndex:0];
        NSString *adContentName = [contentElement name];
        if ([adContentName isEqualToString:@"InLine"]) {
            NSString *adTitle = [[[contentElement elementsForName:@"AdTitle"] firstObject] stringValue];
            NSString *adSystem = [[[contentElement elementsForName:@"AdSystem"] firstObject] stringValue];
            // VAST 2.0 - multiple <Impression>
            NSArray *impressionElements = [contentElement elementsForName:@"Impression"];
            if (impressionElements.count == 1) {
                // VAST 1.0 - multiple <URL>
                impressionElements = [[impressionElements firstObject] elementsForName:@"URL"];
            }
            NSMutableArray *impressionURLs = [NSMutableArray array];
            [impressionElements enumerateObjectsUsingBlock:^(DDXMLElement *impressionElement, NSUInteger idx, BOOL *stop) {
                if ([[impressionElement stringValue] length] > 0) {
                    [impressionURLs addObject:[NSURL URLWithString:[impressionElement stringValue]]];
                }
            }];
            //ad.impressionURLs = impressionURLs;
            
            NSArray *videos = [contentElement elementsForName:@"Video"];
            DDXMLElement *videoElement = nil;
            if (videos && videos.count) {
                videoElement = [videos firstObject];
            }
            else {
                NSArray *creatives = [contentElement elementsForName:@"Creatives"];
                if (creatives && creatives.count) {
                    NSArray *creative = [[creatives firstObject] elementsForName:@"Creative"];
                    if (creative && creative.count) {
                        NSArray *linears = [[creative firstObject] elementsForName:@"Linear"];
                        if (linears && linears.count) {
                            videoElement = [linears firstObject];
                        }
                    }
                }
            }
            // video ad
            if (videoElement) {
                YTAdvInfo *advInfomation = [[YTAdvInfo alloc]init];
                [advInfomation setTitle:adTitle];
                NSArray *durations = [videoElement elementsForName:@"Duration"];
                if (durations && durations.count) {
                    NSString *durationString = [[durations firstObject] stringValue];
                    advInfomation.duration = [YTOnWorldUtility timeIntervalWithString:durationString];
                }
                
                NSArray *videoClicksElements = [videoElement elementsForName:@"VideoClicks"];
                if (videoClicksElements && videoClicksElements.count) {
                    DDXMLElement *clicksElement = [videoClicksElements firstObject];
                    NSArray *clickThroughs = [clicksElement elementsForName:@"ClickThrough"];
                    if (clickThroughs && clickThroughs.count) {
                        advInfomation.touchLink = [[clickThroughs firstObject] stringValue];
                    }
                }
                NSArray *mediaFiles = [videoElement elementsForName:@"MediaFiles"];
                if (mediaFiles && mediaFiles.count) {
                    DDXMLElement *mediaFilesElement = [mediaFiles firstObject];
                    DDXMLElement *mediaFileElement = nil;
                    for (DDXMLElement *elementMF in [mediaFilesElement elementsForName:@"MediaFile"]) {
                        NSString *type = [[elementMF attributeForName:@"type"] stringValue];
                        if ([type isEqualToString:@"mobile/m3u8"] || [type isEqualToString:@"video/mp4"] || [type isEqualToString:@"video/x-mp4"]) {
                            mediaFileElement = elementMF;
                            break;
                        }
                    }
                    NSArray *urls = [mediaFileElement elementsForName:@"URL"];
                    if (urls && urls.count) {
                        mediaFileElement = [urls firstObject];
                    }
                    advInfomation.url = [mediaFileElement stringValue];
                }
                [completionSource setResult:advInfomation];
            }
            else { // banner ad
                YTAdvInfo *advInfomation = [[YTAdvInfo alloc]init];
                [advInfomation setTitle:adTitle];
                NSArray *nonLinearAds = [contentElement elementsForName:@"NonLinearAds"];
                if (nonLinearAds && nonLinearAds.count) {
                    NSArray *nonLinear = [[nonLinearAds firstObject] elementsForName:@"NonLinear"];
                    if (nonLinear && nonLinear.count) {
                        NSArray *urls = [[nonLinear firstObject] elementsForName:@"URL"];
                        if (urls && urls.count) {
                            NSString *link = [[[urls firstObject] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            advInfomation.url = link;
                        }
                    }
                    NSArray *clickThroughs = [[nonLinear firstObject] elementsForName:@"NonLinearClickThrough"];
                    if (clickThroughs && clickThroughs.count) {
                        NSArray *urls = [[clickThroughs firstObject] elementsForName:@"URL"];
                        if (urls && urls.count) {
                            advInfomation.touchLink = urls[0];
                        }
                    }
                }
            }
        }
        else {
            [completionSource setError:[NSError errorWithDomain:@"" code:1 userInfo:nil]];
        }

    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [completionSource setError:error];
    }];*/
    
    
    
    return completionSource.task;
}





@end
