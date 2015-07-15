//
//  AFViewController.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "YTTableViewController.h"
#import "YTTableViewCell.h"
#import "YTGirdItemCell.h"
#import "YTTableHeaderCell.h"
#import "YTContentDetailViewController.h"

@interface YTTableViewController ()
{
    NSMutableArray * m_items;
    NSArray *titles;
    int defaultNumberItems;
}


@end

@implementation YTTableViewController

- (id)initWithStyle:(UITableViewStyle)style withArray:(NSArray *)items{
    self = [super initWithStyle:style];
    if(self) {
        _numberItems = defaultNumberItems = [YTOnWorldUtility collectionViewItemPerRow];
        m_items = [[NSMutableArray alloc]initWithArray:items];
    }
    return self;
}



-(void)setNumberItems:(int)numberItems {
    _numberItems = numberItems;
    defaultNumberItems =_numberItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (_showRevealNavigator )
    {
        
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:revealViewController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
        
        if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
            
            if(_navigatorTitle != nil) {
                self.navigationItem.title = _navigatorTitle;
            }else {
                 self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
            }
           
        }
    }else {
        if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
            if(_navigatorTitle != nil)
                self.navigationItem.title = _navigatorTitle;
            else
                self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
        }
    }
    
    if(_numberItems == 0) {
        _numberItems = defaultNumberItems = 2;
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.tableView reloadData];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
//    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        _numberItems = defaultNumberItems + 1;
//    }else {
//        _numberItems = defaultNumberItems;
//    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return m_items.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    YTTableViewCell *cell = (YTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[YTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(YTTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    
}

#pragma mark - UITableViewDelegate Methods


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat width  = tableView.frame.size.width - 10;
    NSDictionary *itemsDict = m_items[indexPath.section];
    NSDictionary *titleDic = [itemsDict valueForKey:@"title"];
    int mode = [[titleDic valueForKey:@"mode"] intValue];
    int height = 0;
    if(mode == 0) {
        height = floorf(width / _numberItems);
    }else {
        height = floorf((width * 9)/(16 * _numberItems));
    }
    NSArray *subItems = [itemsDict valueForKey:@"content"];
    if(subItems.count < _numberItems)
        return height + 10;
    int delta = subItems.count % _numberItems;
    if(delta > 0) {
        delta = 1;
    }
    float item = (subItems.count / _numberItems) + delta;
    return item * height + 10;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    YTTableHeaderCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"headercell"];
    if(headerCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([YTTableHeaderCell class]) owner:self options:nil];
        headerCell = [nib objectAtIndex:0];
    }
    
    if(_enableMoreButton) {
        [headerCell.btnMore setHidden:NO];
        [headerCell.btnMore addTarget:self
                               action:@selector(click_showMore)
                     forControlEvents:UIControlEventTouchUpInside];
    }else {
        [headerCell.btnMore setHidden:YES];
    }
    
    
    NSDictionary *item = m_items[section];
    NSDictionary *titleDict = [item valueForKey:@"title"];
    
    [headerCell.txtTitle setText:[titleDict valueForKey:@"name"]];
    return headerCell;
}


- (void)click_showMore {
    
}

#pragma mark - UICollectionViewDataSource Methods


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSDictionary *itemsAtPath = m_items[[(YTIndexedCollectionView *)collectionView indexPath].section];
    NSArray *subItems = [itemsAtPath valueForKey:@"content"];
    return subItems.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    
    YTGirdItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *itemsAtPath = m_items[[(YTIndexedCollectionView *)collectionView indexPath].section];
    NSArray *subItems = [itemsAtPath valueForKey:@"content"];
    
    NSDictionary * item = subItems[indexPath.item];
    [cell.txtTitle setText:[item valueForKey:@"name"]];
    
     __weak UIImageView *imageView = cell.imgView;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[item valueForKey:@"image"] completed:^(NSError *error, UIImage *image) {
        if(error == nil) {
            [imageView setImage:image];
        }
    }];
    
    if(_showByCategory){
        cell.txtCategory.text = [item valueForKey:@"category"];
    }else {
        [cell.txtCategory setHidden:YES];
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *itemsAtPath = m_items[[(YTIndexedCollectionView *)collectionView indexPath].section];
    NSDictionary *title = [itemsAtPath valueForKey:@"title"];
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    
    CGFloat width = frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing;
    if(width > 0) {
        width = width / _numberItems;
        CGFloat height = 0;
        if([[title valueForKey:@"mode"] intValue] == 0) {// listen
            height = width;
        }else {//view
            height =floorf((9 * width)/16);
        }
        return CGSizeMake(width,height);
    }
    return CGSizeZero;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *itemdict = m_items[[(YTIndexedCollectionView *)collectionView indexPath].row];

    NSDictionary *item = [[itemdict valueForKey:@"content"] objectAtIndex:indexPath.row];
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    YTContentDetailViewController *detailViewCtrl = [(UIStoryboard *)[YTOnWorldUtility appStoryboard] instantiateViewControllerWithIdentifier:@"detailViewController"];
    [detailViewCtrl setContentID:[[item valueForKey:@"id"] intValue]];
    UINavigationController *navigationController = (UINavigationController*) [self.revealViewController frontViewController];
    [navigationController pushViewController:detailViewCtrl animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
