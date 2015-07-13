//
//  YTAdvViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/13/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTAdvViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *advPlayerView;
@property (weak, nonatomic) IBOutlet UIView *txtLableAdv;
@property (weak, nonatomic) IBOutlet UIView *bottomAdvView;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
- (IBAction)click_skip:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *click_advPlayer;
@property (weak, nonatomic) IBOutlet UIView *advImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgAdv;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseImageAdv;
- (IBAction)click_closeAdd:(id)sender;

@end
