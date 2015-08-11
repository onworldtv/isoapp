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
#import "YTScreenDetailViewController.h"

@interface YTTableViewController ()<UIScrollViewDelegate>
{
    int defaultNumberItems;
    BOOL displayByMode;
    BOOL contentsByGenre;
    YTMode m_mode;
    NSNumber *m_categoryID,*m_providerID;
}


@end

@implementation YTTableViewController

- (id)initWithStyle:(UITableViewStyle)style withArray:(NSArray *)items{
    self = [super initWithStyle:style];
    if(self) {
        _numberItems = defaultNumberItems = [YTOnWorldUtility collectionViewItemPerRow];
        _contentItems = items;
    }
    return self;
}

- (id)initWithMode:(YTMode)mode showInMain:(BOOL)flag{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        m_mode = mode;
        displayByMode = YES;
        contentsByGenre = flag;
    }
    return self;
}

- (id)initWithCategoryID:(NSNumber *)cateID providerID:(NSNumber *)provID showInMain:(BOOL )flag{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        m_categoryID = cateID;
        m_providerID = provID;
        m_mode = -1;
        contentsByGenre = flag;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [DejalBezelActivityView removeViewAnimated:YES];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
}


- (void)viewDidLoad
{
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
                self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWith8BitRed:48 green:125 blue:210]};
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
    
    self.navigationController.navigationBar.topItem.title = @"";
    [super viewDidLoad];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout=UIRectEdgeNone;
        if(_contentItems.count ==0) {
        [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
    }
    
    if(_numberItems == 0) {
        _numberItems = defaultNumberItems = [YTOnWorldUtility collectionViewItemPerRow];
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    BFTask *task = nil;
    if(contentsByGenre) {
        task = [DATA_MANAGER getAllContentInGenre:m_categoryID];
    }else {
        if(m_providerID == nil && m_categoryID) {
            task = [DATA_MANAGER getGroupGenreByCategory:m_categoryID];
        }else if(m_categoryID == nil && m_providerID) {
            task = [DATA_MANAGER getContentsByProviderId:m_providerID];
        }else if(displayByMode){
            task = [DATA_MANAGER getAllCatatgoryByMode:m_mode];
        }else {
            task = [BFTask taskWithResult:nil];
        }
    }
    [task continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _contentItems = task.result;
            [DejalBezelActivityView removeViewAnimated:YES];
            [self.tableView reloadData];
        });
        return nil;
    }];
}

- (void)setContentArray:(NSArray*)arr{
    
    if(self.contentItems.count > 0) {
        return ;
    }
    self.contentItems = arr;
    [self.tableView reloadData];
    [DejalBezelActivityView removeViewAnimated:YES];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {

    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    }

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _contentItems.count;
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
    
    if(_contentItems.count == 1) {
        return tableView.frame.size.height-40;
        
    }else {
        
        CGFloat width  = tableView.frame.size.width - 10;
        NSInteger section = indexPath.section;
        NSDictionary *itemsDict = _contentItems[section];
        NSDictionary *titleDic = [itemsDict valueForKey:@"title"];
        int mode = [[titleDic valueForKey:@"mode"] intValue];
        
        int height = 0;
        if(mode == 0) {
            height = floorf(width / _numberItems) - 5;
        }else {
            height = floorf((width * 9)/(16 * _numberItems)) + 24;
        }
        
        NSArray *subItems = [itemsDict valueForKey:@"content"];
        if(_enableMoreButton && subItems.count > [YTOnWorldUtility numberItemPerTableCell]) {
            return (([YTOnWorldUtility numberItemPerTableCell]/[YTOnWorldUtility collectionViewItemPerRow]) * height) + 10;
        }
        if(subItems.count < _numberItems &&_contentItems.count > 1)
            return height + 30 ;
        int delta = subItems.count % _numberItems;
        if(delta > 0) {
            delta = 1;
        }
        float item = (subItems.count / _numberItems) + delta;
        if(item * height + 10 > tableView.frame.size.height && _contentItems.count >=1) {
            return tableView.frame.size.height- 70;
            
        }else if (item * height + 10 < tableView.frame.size.height && _contentItems.count ==1) {
            return tableView.frame.size.height+10;
        }
        return item * height + 10;
    }


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
    
    NSDictionary *item = _contentItems[section];
    NSDictionary *titleDict = [item valueForKey:@"title"];
    
    NSArray *subItem = item[@"content"];
    if(subItem.count >=6 && _contentItems.count >1) {
        if(_enableMoreButton) {
            [headerCell.btnMore setHidden:NO];
            [headerCell.btnMore setTag:[[titleDict valueForKey:@"id"] intValue]];
            [headerCell.btnMore addTarget:self
                                   action:@selector(click_showMore:)
                         forControlEvents:UIControlEventTouchUpInside];
        }else {
            [headerCell.btnMore setHidden:YES];
        }
    }else {
           [headerCell.btnMore setHidden:YES];
    }
    

    [headerCell.txtTitle setText:[titleDict valueForKey:@"name"]];
    return headerCell;
}



- (void)click_showMore:(UIButton *)sender{
    if([_delegate respondsToSelector:@selector(showAllContentInsideGenre:flag:)]) {
        int tag = (int)sender.tag;
        if(!m_providerID && m_categoryID)
            [_delegate showAllContentInsideGenre:tag flag:YES];
        else
            [_delegate showAllContentInsideGenre:tag flag:NO];
    }
}

#pragma mark - UICollectionViewDataSource Methods


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSDictionary *itemsAtPath = _contentItems[[(YTIndexedCollectionView *)collectionView indexPath].section];
    
    NSArray *subItems = [itemsAtPath valueForKey:@"content"];
    if(subItems.count > [YTOnWorldUtility numberItemPerTableCell] && _enableMoreButton && _contentItems.count >1) {
        collectionView.scrollEnabled = NO;
        return [YTOnWorldUtility numberItemPerTableCell];
    }
    return subItems.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    
    YTGirdItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    NSInteger section = [(YTIndexedCollectionView *)collectionView indexPath].section;
    NSDictionary *itemsAtPath = _contentItems[section];
    NSArray *subItems = [itemsAtPath valueForKey:@"content"];
    NSDictionary * item = subItems[indexPath.item];
    
    [cell.txtTitle setText:[item valueForKey:@"name"]];
    if(_showByCategory){
        cell.txtCategory.text = [item valueForKey:@"category"];
    }else {
        [cell.txtCategory setHidden:YES];
    }

    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:item[@"image"]]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *itemsAtPath = _contentItems[[(YTIndexedCollectionView *)collectionView indexPath].section];
    NSDictionary *title = [itemsAtPath valueForKey:@"title"];
    CGRect frame = collectionView.frame;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
    
    CGFloat width = frame.size.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing;
    if(width > 0) {
        width = width / _numberItems;
        CGFloat height = 0;
        if([[title valueForKey:@"mode"] intValue] == 0) {// listen
            height = width - 5;
        }else {//view
            height =floorf((9 * width)/16)+24;
        }
        return CGSizeMake(width,height);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    

    NSDictionary *itemdict = _contentItems[[(YTIndexedCollectionView *)collectionView indexPath].section];

    NSDictionary *item = [[itemdict valueForKey:@"content"] objectAtIndex:indexPath.row];
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
  
    YTScreenDetailViewController *detailViewCtrl = [(UIStoryboard *)[YTOnWorldUtility appStoryboard]instantiateViewControllerWithIdentifier:@"detailViewController"];
    [detailViewCtrl setContentID:@([[item valueForKey:@"id"] intValue])];
   
    UINavigationController *navigationController = (UINavigationController*) [self.revealViewController frontViewController];
    [navigationController pushViewController:detailViewCtrl animated:YES];
}





- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
