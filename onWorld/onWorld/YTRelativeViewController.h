//
//  YTRelativeViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YTDelegateSelectRelativeItem<NSObject>

- (void)delegateSelectedItem:(NSNumber *)itemID;

@end

@interface YTRelativeViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *m_title;
@property (nonatomic,assign)int numberOfItem;
@property (weak)id<YTDelegateSelectRelativeItem>delegate;

- (id)initWithArray:(NSArray *)array display:(int)modeView;
@end
