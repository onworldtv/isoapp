//
//  YTLoginViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTLoginViewController.h"
#import "SSKeychain.h"
@interface YTLoginViewController ()

@end

@implementation YTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.loginScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_btnRemember setTag:0];// uncheck
    [_txtPassword setSecureTextEntry:YES];

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

- (IBAction)click_remember:(id)sender {
   
    NSInteger tag = !_btnRemember.tag;
    if(tag == 0) {
        [_btnRemember setImage:[UIImage imageNamed:@"box_unchecked"] forState:UIControlStateNormal];
    }else {
        [_btnRemember setImage:[UIImage imageNamed:@"box_checked"] forState:UIControlStateNormal];
    }
    [_btnRemember setTag:tag];
}

- (IBAction)click_login:(id)sender {
    

    if(![self isValidEmail]) {
         [YTOnWorldUtility showError:@"The email address inccorect !"];
        return ;
    }
    NSString *userName = [_txtUserName text];
    NSString *password = [_txtPassword text];
    [self enableControls:NO];
    [NETWORK_MANAGER loginWithUserName:userName
                              passWord:password
                          successBlock:^(AFHTTPRequestOperation *operation, id response) {
                              if(_btnRemember.tag == 1) {//
                                  
                                  //set pass
                                  [SSKeychain setPassword:password
                                               forService:kYTServiceName
                                                  account:kYTAccountName];
//                                  NSString *password = [SSKeychain passwordForService:kYTServiceName account:kYTAccountName];

                              }else { //delete password
                                  
                                  [SSKeychain deletePasswordForService:kYTServiceName account:kYTAccountName];
                              }
                              [self.navigationController popViewControllerAnimated:YES];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [self enableControls:YES];
                              
                              [YTOnWorldUtility showError:[[error userInfo]valueForKey:@"message"]];
                          }];
    
    
}
- (void)enableControls:(BOOL)status {
    
    [_btnRemember setEnabled:status];
    [_btnlogin setEnabled:status];
    [_txtUserName setEnabled:status];
    [_txtPassword setEnabled:status];

}


- (BOOL)isValidEmail {
    return [_txtUserName.text validateEmailAddress];
}
@end
