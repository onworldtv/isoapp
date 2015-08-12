//
//  YTMainViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTMainViewController.h"
#import "YTHomeViewController.h"
#import "YTTableViewController.h"
#import "YTScreenDetailViewController.h"
#import "YTDetailViewCell.h"
#import "YTHomeItemController.h"

@interface YTMainViewController ()
{
    YTHomeViewController *videoViewCtrl;
    YTHomeViewController *audioViewCtrl;
}
@end

@implementation YTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }

    if (!self.navigationItem.title || self.navigationItem.title.length <= 0) {
        self.navigationItem.title = nil;
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    }
    
    [DejalBezelActivityView activityViewForView:[[UIApplication sharedApplication]keyWindow] withLabel:nil];
    BFTask *task = nil;
    if(DATA_MANAGER.homeData.count == 0) {
        task = [DATA_MANAGER contentItemsHomeView];
    }else {
        task = [BFTask taskWithResult:nil];
    }
    
    [task continueWithBlock:^id(BFTask *task) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSDictionary* contentItems = [DATA_MANAGER homeData];
        
        YTHomeItemController *recommendationViewCtrl = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"view.recommend"]
                                                                                             mode:ModeView
                                                                                        indentify:@"recommend" delegate:self];
        

        
        YTHomeItemController *recentAddViewCtrl = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"view.added"]
                                                                                        mode:ModeView
                                                                                   indentify:@"added" delegate:self];
        
        
        
        
        YTHomeItemController *popularViewCtrl = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"view.popular"]
                                                                                      mode:ModeView
                                                                                 indentify:@"popular" delegate:self];
        
        YTHomeItemController *audioRecomemdation = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"listen.recommend"]
                                                                                         mode:ModeListen
                                                                                    indentify:@"recommend" delegate:self];
        
        YTHomeItemController *audioRecent = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"listen.added"]
                                                                                  mode:ModeListen
                                                                             indentify:@"added" delegate:self];
        
        YTHomeItemController *audioPopular = [[YTHomeItemController alloc]initWithArray:[contentItems valueForKeyPath:@"listen.popular"]
                                                                                   mode:ModeListen
                                                                              indentify:@"popular" delegate:self];
        
        videoViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's view today"];
        [videoViewCtrl setMode:1];
        [videoViewCtrl setViewControllers:@[recommendationViewCtrl, recentAddViewCtrl, popularViewCtrl]];
        [videoViewCtrl setDelegate:self];
        [videoViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        audioViewCtrl = [[YTHomeViewController alloc]initWithTitle:@"What's listen today"];
        [audioViewCtrl setMode:0];
        [audioViewCtrl setViewControllers:@[audioRecomemdation,audioRecent,audioPopular]];
        [audioViewCtrl setDelegate:self];
        [audioViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [_tableView reloadData];
        return nil;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)delegateShowDetailContentID:(NSNumber*)contentID {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    
    YTScreenDetailViewController *detailViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    [detailViewCtrl setContentID:contentID];
    UINavigationController *navigationController = (UINavigationController*) [self.revealViewController frontViewController];
    [navigationController pushViewController:detailViewCtrl animated:YES];
}


- (void)delegateShowMoreCategoryByMode:(int)mode {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    YTTableViewController *moreViewController  = [[YTTableViewController alloc]initWithMode:mode showInMain:NO];
    [moreViewController setDelegate:self];
    [moreViewController setEnableMoreButton:YES];
    UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
    [navCtrll pushViewController:moreViewController animated:YES];

}


- (void)showAllContentInsideGenre:(int)genreID flag:(BOOL)flag {
    
    YTTableViewController *moreCategoriesViewController  = [[YTTableViewController alloc]initWithCategoryID:@(genreID) providerID:nil showInMain:flag];
    [moreCategoriesViewController setShowByCategory:NO];
    UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
    [navCtrll pushViewController:moreCategoriesViewController animated:YES];
}



#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentify = @"Cell";
    YTDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if(cell) {
        if(indexPath.row == 0) {
            CGRect viewFrame = videoViewCtrl.view.frame;
            viewFrame.size.width = self.tableView.frame.size.width;
            viewFrame.size.height = [self heighTableCellWithMode:1];
            [cell.contentView setFrame:viewFrame];
            videoViewCtrl.view.frame = viewFrame;

            [cell.contentView addSubview:videoViewCtrl.view];
        }else {
            CGRect viewFrame = audioViewCtrl.view.frame;
            viewFrame.size.width = self.tableView.frame.size.width;
            viewFrame.size.height = [self heighTableCellWithMode:0];
            [cell.contentView setFrame:viewFrame];
            audioViewCtrl.view.frame = viewFrame;
            cell.contentView.frame = viewFrame;
            [cell.contentView addSubview:audioViewCtrl.view];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        return [self heighTableCellWithMode:1];
    }else {
        return [self heighTableCellWithMode:0];
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}



- (int)heighTableCellWithMode:(int)mode {
    CGRect mainFrame = [[UIScreen mainScreen] bounds];
    int itemWith = mainFrame.size.width / [YTOnWorldUtility collectionViewItemPerRow];
    int itemHeight = 0;
    if(mode == 0) {
        itemHeight = itemWith - 5;
    }else {
        itemHeight = floorf((9 * itemWith)/16)+24;
    }
    return itemHeight *3 + 95;
}

@end
