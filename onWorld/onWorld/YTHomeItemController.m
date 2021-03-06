//
//  YTHomeItemController.m
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTHomeItemController.h"
#import "YTGirdItemCell.h"

@interface YTHomeItemController () 
{
    NSArray *contentItems;
    int m_mode;
    id<YTSelectedItemProtocol> m_delegate;

}
@end

@implementation YTHomeItemController

- (id)initWithArray:(NSArray *)array mode:(int)mode indentify:(NSString *)identify delegate:(id<YTSelectedItemProtocol>)delegate  {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        contentItems = array;
        _identify = identify;
        m_mode = mode;
        m_delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     [self.collectionView registerClass:[YTGirdItemCell class] forCellWithReuseIdentifier:@"itemCell"];
  
    [self.collectionView setScrollEnabled:NO];
    [self.collectionView reloadData];
}


//- (void)viewWillDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//}

- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return contentItems.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    YTGirdItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    NSDictionary *contentItem = contentItems[indexPath.row];
    itemCell.txtCategory.text = [contentItem valueForKey:@"category"];
    itemCell.txtTitle.text = [contentItem valueForKey:@"name"];
    
    [itemCell.imgView sd_setImageWithURL:[NSURL URLWithString:[contentItem valueForKey:@"image"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
 
    return itemCell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int number = [YTOnWorldUtility collectionViewItemPerRow];
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    
    CGFloat width = (frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing) / number;
    
    if(width > 0) {
        CGFloat height = 0;
        if(m_mode == 0) {// listen
            height = width - 5;
        }else {//view
            height =floorf((9 * width)/16)+24;
        }
        return CGSizeMake(width,height);
    }
    return CGSizeMake(width, HEIGHT_COLLECTION_ITEM);
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    NSDictionary *item = contentItems[indexPath.row];
    if(item) {
        if([m_delegate respondsToSelector:@selector(delegateShowDetailContentID:)]) {
            [m_delegate delegateShowDetailContentID:@([[item valueForKey:@"id"] integerValue])];
        }
    }
}
@end
