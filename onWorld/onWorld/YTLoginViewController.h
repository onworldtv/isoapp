//
//  YTLoginViewController.h
//  OnWorld
//
//  Created by yestech1 on 6/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;

@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnRemember;

- (IBAction)click_remember:(id)sender;
- (IBAction)click_login:(id)sender;

@end
