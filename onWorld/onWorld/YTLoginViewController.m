//
//  YTLoginViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTLoginViewController.h"
#import "PDKeychainBindings.h"
@interface YTLoginViewController ()

@end

@implementation YTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.loginScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_btnRemember setTag:0];// uncheck
    [_txtPassword setSecureTextEntry:YES];
    
    [_txtUserName becomeFirstResponder];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([userdefault boolForKey:REMEMBER_LOGIN]) {
        NSString *username = [[PDKeychainBindings sharedKeychainBindings] objectForKey:USERNAME];
        NSString *password = [[PDKeychainBindings sharedKeychainBindings] objectForKey:PASSWORD];
        [_txtUserName setText:username];
        [_txtPassword setText:password];
    }else {
        // remove
        [[PDKeychainBindings sharedKeychainBindings] removeObjectForKey:USERNAME];
        [[PDKeychainBindings sharedKeychainBindings]removeObjectForKey:PASSWORD];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - keyboard notification
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
//    if (_keyboardIsShown) return;
//    
//    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGRect convertedFrame = [self.view convertRect:keyboardFrame fromView:nil];
//    CGRect containerFrame = self.containterView.frame;
//    containerFrame.size.height -= convertedFrame.size.height;
//    self.containterView.frame = containerFrame;
//    _keyboardIsShown = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
//    CGRect containerFrame = self.containterView.frame;
//    containerFrame.size.height = self.view.bounds.size.height;
//    self.containterView.frame = containerFrame;
//    _keyboardIsShown = NO;
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
    
    if([_txtUserName.text isEqualToString:@""]) {
        [YTOnWorldUtility showError:@"Please enter email address."];
        return ;
    }
    if([_txtPassword.text isEqualToString:@""]){
        [YTOnWorldUtility showError:@"Please enter password."];
        return;
    }

    if(![self isValidEmail]) {
         [YTOnWorldUtility showError:@"The email address inccorect !"];
        return ;
    }
    NSString *userName = [_txtUserName text];
    NSString *password = [_txtPassword text];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:nil];
    
    [NETWORK_MANAGER loginWithUserName:userName
                              passWord:password
                          successBlock:^(AFHTTPRequestOperation *operation, id response) {
                              [DejalBezelActivityView removeViewAnimated:YES];
                              NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
                              if(_btnRemember.tag == 1) {//
                                  [userdefault setBool:YES forKey:REMEMBER_LOGIN];
                                  
                                  [[PDKeychainBindings sharedKeychainBindings]setObject:userName forKey:USERNAME];
                                  [[PDKeychainBindings sharedKeychainBindings]setObject:password forKey:PASSWORD];
                              }else {
                                  [userdefault setBool:NO forKey:REMEMBER_LOGIN];
                                  [[PDKeychainBindings sharedKeychainBindings]removeObjectForKey:USERNAME];
                                  [[PDKeychainBindings sharedKeychainBindings]removeObjectForKey:PASSWORD];
                              }
                              [self.navigationController popViewControllerAnimated:YES];
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              [DejalBezelActivityView removeViewAnimated:YES
                               ];
                              
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
