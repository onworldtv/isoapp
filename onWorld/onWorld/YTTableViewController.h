//
//  AFViewController.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTTableViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,assign)int numberItems;
@property (nonatomic,assign)BOOL enableMoreButton;

@end
