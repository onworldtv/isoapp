//
//  YTGridViewController.h
//  OnWorld
//
//  Created by yestech1 on 6/26/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTSelectedItemProtocol.h"
@interface YTGridViewController : UICollectionViewController

@property (weak) id<YTSelectedItemProtocol> delegate;

- (id)initWithIdentify:(NSString *)identify mode:(int)mode;
- (id)initWithArray:(NSArray *)array;
- (void)setNumberItem:(int)item;
- (void)setContentsView:(NSArray *)contents;
- (NSString *)identify;
@end
