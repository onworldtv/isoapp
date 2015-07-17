//
//  YTPlayerViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import "YTSlider.h"
@interface YTPlayerViewController : UIViewController <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (retain,nonatomic)NSURL * urlPath;

@property (nonatomic, weak) IBOutlet YTSlider* sliderTrackView;
@property (weak,nonatomic)IBOutlet YTPlayerView *playerView;

@property (nonatomic, weak) IBOutlet UIView* topView;
@property (nonatomic, weak) IBOutlet UIView* imgAdvView;
@property (nonatomic, weak) IBOutlet UIView* topViewAdv;
@property (nonatomic, weak) IBOutlet UIView* bottomViewAdv;
@property (weak, nonatomic) IBOutlet UILabel *lbAdvSecondTime;
@property (nonatomic, weak) IBOutlet UIView* liveView;
@property (nonatomic, weak) IBOutlet UIView* bottomView;
@property (nonatomic, weak) IBOutlet UIView* scheduleView;


@property (nonatomic, weak) IBOutlet MPVolumeView * volumnView;
@property (nonatomic, weak) IBOutlet UIButton* btnCloseImageViewAdv;
@property (nonatomic, weak) IBOutlet UIButton* btnSkip;
@property (nonatomic, weak) IBOutlet UIButton* btnPlay;
@property (nonatomic, weak) IBOutlet UIButton* btnPlayList;
@property (nonatomic, weak) IBOutlet UIButton* btnCast;

@property (weak, nonatomic) IBOutlet UILabel *txtDurated;
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UITableView *tbvTableView;

@property (nonatomic, weak) IBOutlet UIImageView* imageAdvView;

- (IBAction)click_closePlayer:(id)sender;
- (IBAction)click_cast:(id)sender;
- (IBAction)click_playlist:(id)sender;
- (IBAction)click_play:(id)sender;
- (IBAction)click_closeAdvImageView:(id)sender;
- (IBAction)click_skip:(id)sender;

- (IBAction)click_AdvView:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil itemID:(int)ID;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
@end
