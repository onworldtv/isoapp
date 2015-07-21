//
//  YTDetailViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTDetailViewController : UIViewController
@property (assign,nonatomic)int contentID;
@property (weak, nonatomic) IBOutlet UILabel *txtGenre;
@property (weak, nonatomic) IBOutlet UILabel *txtContentName;
@property (weak, nonatomic) IBOutlet UILabel *txtNational;
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtYear;
@property (weak, nonatomic) IBOutlet UITextView *lbDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak)id<YTSelectedItemProtocol>delegate;

- (IBAction)click_show:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgBanner;
- (IBAction)click_player:(id)sender;
@end
