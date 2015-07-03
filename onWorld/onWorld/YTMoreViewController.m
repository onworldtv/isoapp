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
}

@end

@implementation YTMoreViewController


- (id)init {
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        moreViewController = [[YTTableViewController alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    moreViewController.view.frame = self.view.bounds;
    
    [moreViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
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
