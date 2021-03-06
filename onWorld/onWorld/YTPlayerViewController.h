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
@interface YTPlayerViewController : UIViewController <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,ChromecastControllerDelegate,YTSelectedItemProtocol>

@property (retain,nonatomic)NSURL * urlPath;

@property (nonatomic, weak) IBOutlet YTSlider* sliderTrackView;
@property (weak, nonatomic) IBOutlet UISlider *slidervolume;


@property (weak,nonatomic)IBOutlet YTPlayerView *playerView;

@property (nonatomic, weak) IBOutlet UIView* topView;
@property (nonatomic, weak) IBOutlet UIView* imgAdvView;
@property (nonatomic, weak) IBOutlet UIView* topViewAdv;
@property (nonatomic, weak) IBOutlet UIView* bottomViewAdv;
@property (weak, nonatomic) IBOutlet UILabel *lbAdvSecondTime;
@property (nonatomic, weak) IBOutlet UIView* liveView;
@property (nonatomic, weak) IBOutlet UIView* bottomView;
@property (nonatomic, weak) IBOutlet UIView* scheduleView;


@property (nonatomic, weak) IBOutlet UIView* contentLiveView;
@property (nonatomic, weak) IBOutlet UIView* testView;

@property (nonatomic, weak) IBOutlet MPVolumeView * volumnView;
@property (nonatomic, weak) IBOutlet UIButton* btnCloseImageViewAdv;
@property (nonatomic, weak) IBOutlet UIButton* btnSkip;
@property (nonatomic, weak) IBOutlet UIButton* btnPlay;
@property (nonatomic, weak) IBOutlet UIButton* btnPlayList;
@property (nonatomic, weak) IBOutlet UIButton* btnCast;

@property (weak, nonatomic) IBOutlet UILabel *txtTimePlaying;
@property (weak, nonatomic) IBOutlet UILabel *txtTotalTime;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UITableView *tbvTableView;
@property (weak, nonatomic) IBOutlet UITableView *tbvEpisodes;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightScheduleViewContraint;

@property (nonatomic, weak) IBOutlet UIImageView* imageAdvView;
@property (nonatomic, weak) IBOutlet UIImageView* imageBanner;
- (IBAction)click_closePlayer:(id)sender;
- (IBAction)click_cast:(id)sender;
- (IBAction)click_playlist:(id)sender;
- (IBAction)click_play:(id)sender;
- (IBAction)click_closeAdvImageView:(id)sender;
- (IBAction)click_skip:(id)sender;

- (IBAction)click_AdvView:(id)sender;

- (id)initWithID:(NSNumber*)ID;

- (id)initWithIndexSchedule:(int)index_schedule indexTimeline:(NSNumber *)timelineID contentID:(NSNumber*)contentID;

- (id)initPlayID:(NSNumber *)ID episodesID:(NSNumber *)episodesID;

- (IBAction)volumeChanged:(id)sender;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
@end
