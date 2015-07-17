//
//  YTConstant.h
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <Foundation/Foundation.h>




// for NSUserDefault

#define USERNAME          @"username"
#define PASSWORD          @"password"
#define REMEMBER_LOGIN    @"remember_login"
#define ACCESS_TOKEN      @"access_token"
#define USERID            @"userid"


#define HEIGHT_COLLECTION_ITEM      200

//0:single; 1: serie; 2:episode
typedef NS_ENUM(NSUInteger, FileType) {
    TypeSingle,
    TypeSerie,
    TypeEpisode,
};



typedef NS_ENUM(NSUInteger, YTMode) {
    ModeListen,
    ModeView,
};

typedef NS_ENUM(NSUInteger, YTAdvType) {
    TypeVideo,
    TypeImage,
};
