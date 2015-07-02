//
//  YTDetailViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *txtGenre;
@property (weak, nonatomic) IBOutlet UILabel *txtNational;
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtYear;
@property (weak, nonatomic) IBOutlet UILabel *lbDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
- (IBAction)click_show:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgBanner;
- (IBAction)click_player:(id)sender;
@end
