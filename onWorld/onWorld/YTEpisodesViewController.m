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
{
    NSArray *contentItem;
}

@end

@implementation YTEpisodesViewController



- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self) {
        contentItem = [[NSArray alloc]init];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
    return contentItem.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
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
    
//    cell.txtContentName.text = @"";
//    cell.txtEpisodes.text = @"";
    
    return cell;
}



@end
