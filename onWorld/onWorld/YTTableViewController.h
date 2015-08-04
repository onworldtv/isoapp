//
//  AFViewController.h
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YTTableViewController : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong)NSString * navigatorTitle;
@property (nonatomic,assign)BOOL       showRevealNavigator;
@property (nonatomic,assign)BOOL       showByCategory; // show genre group
@property (nonatomic,assign)int numberItems;
@property (nonatomic,assign)BOOL enableMoreButton;
@property (nonatomic,strong)NSArray * contentItems;
@property (weak)id<YTSelectedItemProtocol>delegate;
- (id)initWithStyle:(UITableViewStyle)style withArray:(NSArray *)items;


- (id)initWithCategoryID:(NSNumber *)cateID providerID:(NSNumber *)provID showInMain:(BOOL )flag;

- (id)initWithMode:(YTMode)mode showInMain:(BOOL)flag;
@end
