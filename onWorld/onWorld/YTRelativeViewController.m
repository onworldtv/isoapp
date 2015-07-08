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
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        _numberOfItem = defaultNumber = [YTOnWorldUtility collectionViewItemPerRow];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if(_mode == 0){
        _m_title.text = @"LISTEN RELATED";
    }else {
        _m_title.text = @"VIEW RELATED";
    }
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [self.collectionView registerClass:[YTGirdItemCell class] forCellWithReuseIdentifier:@"itemCell"];


}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
    [_collectionView reloadData];
}
- (void)setMode:(int)mode {
    _mode = mode;
    if(_mode == 0){
        _m_title.text = @"LISTEN RELATED";
    }else {
        _m_title.text = @"VIEW RELATED";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setNumberOfItem:(int)numberOfItem {
    _numberOfItem = numberOfItem;
    defaultNumber = _numberOfItem;
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
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = _items[indexPath.row];
    YTGirdItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    cell.txtTitle.text = [item valueForKey:@"name"];
    [cell.txtCategory setHidden:YES];
    __weak UIImageView *imageView = cell.imgView;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[item valueForKey:@"image"] completed:^(NSError *error, UIImage *image) {
        [imageView setImage:image];
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CGFloat width = (frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / _numberOfItem;
   
    if(width > 0) {
        CGFloat height = 0;
        if(_mode == 0) {// listen
            height = width;
        }else {//view
            height =floorf((9 * width)/16);
        }
        return CGSizeMake(width,height);
    }

    
    return CGSizeMake(width, HEIGHT_COLLECTION_ITEM);
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item  =_items[indexPath.row];
    if(item) {
        if([_delegate respondsToSelector:@selector(didSelectItemWithCategoryID:)]) {
            [_delegate didSelectItemWithCategoryID:[[item valueForKey:@"id"] intValue]];
        }
    }
    [UIView animateWithDuration:0.5 animations:^{
        [collectionView setContentOffset:CGPointMake(0, 0)];
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];

}
@end
