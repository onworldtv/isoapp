//
//  YTGridViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/26/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTGridViewController.h"
#import "YTGirdViewLayoutCustom.h"
#import "YTGirdItemCell.h"
static NSString * const itemCellIdentify = @"itemCell";

@interface YTGridViewController () {
    NSMutableArray *contentItems;
    int numberItem;
    NSString *m_identify;
    int m_mode;
}

@property (nonatomic, weak) IBOutlet YTGirdViewLayoutCustom *mylayout;
@end

@implementation YTGridViewController

static NSString * const reuseIdentifier = @"Cell";


- (id)initWithArray:(NSArray *)array{
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        if(array) {
            contentItems = [NSMutableArray arrayWithArray:array];
          
        }else {
            contentItems = [NSMutableArray array];
        }
        numberItem = [YTOnWorldUtility collectionViewItemPerRow];
    }
    return self;
}

- (id)initWithIdentify:(NSString *)identify mode:(int)mode{
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        m_mode = mode;
        m_identify = identify;
        numberItem = [YTOnWorldUtility collectionViewItemPerRow];
    }
    return self;
}

- (NSString *)identify {
    return m_identify;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   [self.mylayout setMode:m_mode];
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.mylayout.numberOfColumns = numberItem +1;
    }else {
        self.mylayout.numberOfColumns = numberItem;
    }
    
    [self.collectionView registerClass:[YTGirdItemCell class]
            forCellWithReuseIdentifier:itemCellIdentify];
}


- (void)setContentsView:(NSArray *)contents {
    contentItems = [NSMutableArray arrayWithArray:contents];
    [self.collectionView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
     [self.mylayout setMode:m_mode];
    [super viewWillAppear:animated];
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.mylayout.numberOfColumns = numberItem + 1;
    }else {
        self.mylayout.numberOfColumns = numberItem;
    }
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return contentItems.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTGirdItemCell *itemCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:itemCellIdentify forIndexPath:indexPath];
    NSDictionary *contentItem = contentItems[indexPath.section];
    itemCell.txtCategory.text = [contentItem valueForKey:@"category"];
    itemCell.txtTitle.text = [contentItem valueForKey:@"name"];
    __weak UIImageView *imageView = itemCell.imgView;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[contentItem valueForKey:@"image"]
                                          completed:^(NSError *error, UIImage *image) {
                                              if ( imageView == nil ) return;
                                              
                                              if (error == nil)
                                              {
                                                  imageView.image = image;
                                              }}];
    return itemCell;
}

- (void)setNumberItem:(int)item{
    self.mylayout.numberOfColumns = item;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contentItem = contentItems[indexPath.section];
    if(contentItem) {
        if([_delegate respondsToSelector:@selector(didSelectItemWithCategoryID:)]) {
            [_delegate didSelectItemWithCategoryID:[[contentItem valueForKey:@"id"] intValue]];
        }
    }
}


#pragma mark <UICollectionViewDelegate>

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
