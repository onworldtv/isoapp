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
    [[DATA_MANAGER contentItemsHomeView]continueWithBlock:^id(BFTask *task) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSDictionary* contentItems = task.result;
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)didSelectItemWithCategoryID:(NSNumber*)contentID {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    
    YTScreenDetailViewController *detailViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
    [detailViewCtrl setContentID:contentID];
    UINavigationController *navigationController = (UINavigationController*) [self.revealViewController frontViewController];
    [navigationController pushViewController:detailViewCtrl animated:YES];
}


- (void)delegateDisplayMoreCategoryMode:(int)mode {
    
    NSArray *categories = [YTCategory MR_findByAttribute:@"mode" withValue:@(mode)];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (YTCategory *catgory in categories) {
        NSArray *genries = [[catgory genre]allObjects];
        if(genries.count > 0) {
            for (YTGenre *genre in genries) {
                NSDictionary *genreDict = @{@"id":catgory.cateID, @"name": catgory.name,@"mode":@(mode)};
                NSMutableArray *subItems = [NSMutableArray array];
                
                NSArray *contents = [[genre content]allObjects];
                for (YTContent *content in contents) {
                    
                    NSDictionary *contentDict = @{@"id":content.contentID,
                                                  @"name":content.name,
                                                  @"image":content.image,
                                                  @"desc":content.desc,
                                                  @"category":catgory.name};
                    
                    [subItems addObject:contentDict];
                }
                if(subItems.count > 0) {
                    NSDictionary *object = @{@"title":genreDict, @"content":subItems};
                    [items addObject:object];
                }
            }
        }
    }
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    YTTableViewController *moreViewController  = [[YTTableViewController alloc]initWithStyle:UITableViewStylePlain withArray:items];
    [moreViewController setEnableMoreButton:YES];
    UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
    [navCtrll pushViewController:moreViewController animated:YES];

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
            [cell.contentView setFrame:viewFrame];
            videoViewCtrl.view.frame = viewFrame;
            [cell.contentView addSubview:videoViewCtrl.view];
        }else {
            CGRect viewFrame = videoViewCtrl.view.frame;
            viewFrame.size.width = self.tableView.frame.size.width;
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
        return videoViewCtrl.view.frame.size.height;
    }else {
        return audioViewCtrl.view.frame.size.height;
    }
}



@end
