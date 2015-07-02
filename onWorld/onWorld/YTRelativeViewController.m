//
//  YTRelativeViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTRelativeViewController.h"
#import "YTGirdItemCell.h"
@interface YTRelativeViewController ()
{
    int defaultNumber;
}
@end

@implementation YTRelativeViewController


-(id)init {
    self = [super init];
    if(self) {
        _numberOfItem = defaultNumber = 2;
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [self.collectionView registerClass:[YTGirdItemCell class] forCellWithReuseIdentifier:@"itemCell"];


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
}



- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _numberOfItem = defaultNumber + 1;
    }else {
        _numberOfItem = defaultNumber;
    }
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YTGirdItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CGFloat width = (frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / _numberOfItem;
   
    return CGSizeMake(width, HEIGHT_COLLECTION_ITEM);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
@end
