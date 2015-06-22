//
//  ViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "ViewController.h"
#import "YTNetWorkManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[YTNetWorkManager shareNetworkManager] loginWithUserName:@"onworldtv1234@yopmail.com"
                                                     passWord:@"123456"
                                                 successBlock:^(AFHTTPRequestOperation *operation, id response) {
                                                     
                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     
                                                 }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
