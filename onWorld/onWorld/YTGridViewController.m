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

@interface YTGridViewController ()

@property (nonatomic, weak) IBOutlet YTGirdViewLayoutCustom *mylayout;
@end

@implementation YTGridViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    self.mylayout.itemSize = CGSizeMake(153, 180);
    [self.collectionView registerClass:[YTGirdItemCell class]
            forCellWithReuseIdentifier:itemCellIdentify];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear", self.title);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@ viewDidAppear", self.title);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@ viewWillDisappear", self.title);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%@ viewDidDisappear", self.title);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    NSLog(@"%@ willMoveToParentViewController %@", self.title, parent);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    NSLog(@"%@ didMoveToParentViewController %@", self.title, parent);
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTGirdItemCell *itemCell =
    [collectionView dequeueReusableCellWithReuseIdentifier:itemCellIdentify
                                              forIndexPath:indexPath];
    return itemCell;
}

- (void)setSize:(CGSize)size numberItem:(int)item{
    self.mylayout.numberOfColumns = item;
    // handle insets for iPhone 4 or 5
    self.mylayout.itemSize = size;
}



#pragma mark <UICollectionViewDelegate>



/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
