//
//  YTDetailViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTDelegatePlayItem <NSObject>

@optional
- (void)delegatePlayItemWithID:(NSNumber *)itemID;

@end


@interface YTDetailViewController : UIViewController
@property (assign,nonatomic)int contentID;

@property (weak, nonatomic) IBOutlet UILabel *txtGenre;
@property (weak, nonatomic) IBOutlet UILabel *txtContentName;
@property (weak, nonatomic) IBOutlet UILabel *txtNational;
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtYear;
@property (weak, nonatomic) IBOutlet UITextView *lbDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnExpand;
@property (weak)id<YTDelegatePlayItem>delegate;


@property (weak, nonatomic) IBOutlet UIView * timelineView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBanner;

- (id)initWithContent:(YTContent *)content timelineView:(UIViewController *)timelineCtrl;
- (id)initWithContent:(YTContent*)content;

- (IBAction)click_player:(id)sender;


@end
