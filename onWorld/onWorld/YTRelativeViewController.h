//
//  YTRelativeViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTRelativeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *m_title;
@property (nonatomic,assign)int numberOfItem;
@property (nonatomic,strong) NSMutableArray * items;
@property (assign,nonatomic)int mode;
@property (weak)id<YTSelectedItemProtocol>delegate;

@end
