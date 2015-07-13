//
//  YTAdvInfo.h
//  OnWorld
//
//  Created by yestech1 on 7/13/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTAdvInfo : NSObject
@property (retain,nonatomic) NSString *url;
@property (retain,nonatomic) NSString *title;
@property (retain,nonatomic) NSString *touchLink;
@property (assign,nonatomic) NSTimeInterval duration;
@property (assign,nonatomic) int type;
@property (assign,nonatomic) int skip;
@property (assign,nonatomic) int skipTime;
@property (assign,nonatomic) int start;

@end
