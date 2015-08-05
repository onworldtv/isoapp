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
    NSArray *arrayRelatives;
    int mode;

}
@end

@implementation YTRelativeViewController




- (id)initWithArray:(NSArray *)array display:(int)modeView {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        _numberOfItem = defaultNumber = [YTOnWorldUtility collectionViewItemPerRow];
        arrayRelatives = array;
        mode = modeView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(mode == 0){
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
    return arrayRelatives.count;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YTContent *item = arrayRelatives[indexPath.row];
    YTGirdItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    cell.txtTitle.text = item.name;
    [cell.txtCategory setHidden:YES];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:item.image]
                    placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CGFloat width = (frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / _numberOfItem;
   
    if(width > 0) {
        CGFloat height = 0;
        if(mode == 0) {// listen
            height = width - 5;
        }else {//view
            height =floorf((9 * width)/16);
        }
        return CGSizeMake(width,height+24);
    }
    return CGSizeMake(width, HEIGHT_COLLECTION_ITEM);
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    YTContent *item  =arrayRelatives[indexPath.row];
    if(item) {
        if([_delegate respondsToSelector:@selector(delegateSelectedItem:)]) {
            [_delegate delegateSelectedItem:item.contentID];
        }
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];

}
@end
