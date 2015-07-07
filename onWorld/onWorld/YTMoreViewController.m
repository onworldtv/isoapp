//
//  YTMoreViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/30/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTMoreViewController.h"
#import "YTTableViewController.h"
@interface YTMoreViewController () {
    YTTableViewController *moreViewController;
    NSArray * items;
}

@end

@implementation YTMoreViewController


- (id)initWithArray:(NSArray *)array {
    self = [super init];
    if(self) {
        moreViewController = [[YTTableViewController alloc]initWithStyle:UITableViewStylePlain withArray:array numberItem:2];
    }
    return self;
}
- (id)init{
    self =[super init];
    if(self) {
        
        moreViewController = [[YTTableViewController alloc]initWithStyle:UITableViewStylePlain];
    }  
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    moreViewController.view.frame = self.view.bounds;
    [moreViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:moreViewController.view];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
