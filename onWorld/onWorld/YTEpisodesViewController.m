//
//  YTEpisodesViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTEpisodesViewController.h"
#import "YTEpisodesViewCell.h"
@interface YTEpisodesViewController ()


@end

@implementation YTEpisodesViewController



- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self) {
        _contentItems = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register Class for Cell Reuse Identifier
    
    UINib *nib = [UINib nibWithNibName:@"YTEpisodesViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"cellIdentify"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setContentItems:(NSMutableArray *)contentItems {
    _contentItems = contentItems;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NSDictionary *item = _contentItems[indexPath.row];
    YTEpisodesViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cellIdentify"];
    if (!cell)
    {
        cell = [[YTEpisodesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentify"];
    }
    cell.avatar.layer.borderWidth = 3.0f;
    cell.avatar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2;
    cell.avatar.clipsToBounds = YES;
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    __weak UIImageView *imageView = cell.avatar;
    
    [[DLImageLoader sharedInstance]loadImageFromUrl:[item valueForKey:@"image"] completed:^(NSError *error, UIImage *image) {
        [imageView setImage:image];
    }];
    

    
    cell.txtContentName.text = @"Noi tinh Yeu bat dau";
    cell.txtEpisodes.text = @"Tap 2";
    
    return cell;
}



@end
