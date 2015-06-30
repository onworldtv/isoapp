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
}

@property (nonatomic, weak) IBOutlet YTGirdViewLayoutCustom *mylayout;
@end

@implementation YTGridViewController

static NSString * const reuseIdentifier = @"Cell";


- (id)initWithArray:(NSArray *)array numberItem:(int)number{
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        if(array) {
            contentItems = [NSMutableArray arrayWithArray:array];
          
        }else {
            contentItems = [NSMutableArray array];
        }
        numberItem = number;
    }
    return self;
}

- (id)initWithIdentify:(NSString *)identify numberItem:(int)number {
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        m_identify = identify;
        numberItem = number;
    }
    return self;
}

- (NSString *)identify {
    return m_identify;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [super viewWillAppear:animated];
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.mylayout.numberOfColumns = numberItem + 1;
    }else {
        self.mylayout.numberOfColumns = numberItem;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
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
    [collectionView dequeueReusableCellWithReuseIdentifier:itemCellIdentify
                                              forIndexPath:indexPath];
    NSDictionary *contentItem = contentItems[indexPath.section];
    itemCell.txtCategory.text = [contentItem valueForKey:@"category"];
    itemCell.txtTitle.text = [contentItem valueForKey:@"name"];
    __weak UIImageView *loadMe = itemCell.imgView;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[contentItem valueForKey:@"image"]
                                          completed:^(NSError *error, UIImage *image) {
                                              if ( loadMe == nil ) return;
                                              
                                              if (error == nil)
                                              {
                                                  loadMe.image = image;
                                              }}];
    
    return itemCell;
}

- (void)setNumberItem:(int)item{
    self.mylayout.numberOfColumns = item;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark <UICollectionViewDelegate>

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
