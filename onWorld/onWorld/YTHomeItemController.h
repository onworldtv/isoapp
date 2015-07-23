//
//  YTHomeItemController.h
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTHomeItemController : UIViewController
@property (weak,nonatomic)IBOutlet UICollectionView * collectionView;
@property (retain,nonatomic)NSString *identify;
- (id)initWithArray:(NSArray *)array mode:(int)mode indentify:(NSString *)identify delegate:(id<YTSelectedItemProtocol>)delegate;
@end
