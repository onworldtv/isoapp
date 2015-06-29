//
//  YTGridViewController.h
//  OnWorld
//
//  Created by yestech1 on 6/26/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTGridViewController : UICollectionViewController


- (id)initWithArray:(NSArray *)array numberItem:(int)number;
- (void)setNumberItem:(int)item;
@end
