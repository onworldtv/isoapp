//
//  YTPlayerViewController.h
//  OnWorld
//
//  Created by yestech1 on 7/1/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
@interface YTPlayerViewController : UIViewController <UIGestureRecognizerDelegate>

@property (retain,nonatomic)NSURL * urlPath;

@property (nonatomic, weak) IBOutlet UISlider* sliderTrackView;
@property (nonatomic, weak) IBOutlet UISlider* sliderVolumview;
@property (weak,nonatomic)IBOutlet YTPlayerView *playerView;
@property (nonatomic, weak) IBOutlet UIView* topView;
@property (nonatomic, weak) IBOutlet UIView* bottomView;
@property (nonatomic, weak) IBOutlet MPVolumeView * volumnView;
@property (nonatomic, weak) IBOutlet UIView* scheduleView;
@property (nonatomic, weak) IBOutlet UIView* timelineView;
@property (nonatomic, weak) IBOutlet UIButton* btnPlay;
@property (nonatomic, weak) IBOutlet UIButton* btnPlayList;
@property (nonatomic, weak) IBOutlet UIButton* btnCast;
@property (weak, nonatomic) IBOutlet UILabel *txtDurated;
@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
- (IBAction)click_closePlayer:(id)sender;
- (IBAction)click_cast:(id)sender;
- (IBAction)click_playlist:(id)sender;
- (IBAction)click_play:(id)sender;




@end
