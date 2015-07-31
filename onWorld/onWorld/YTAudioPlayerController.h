//
//  YTAudioPlayerController.h
//  OnWorld
//
//  Created by yestech1 on 7/16/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YTAudioPlayerController : UIViewController <ChromecastControllerDelegate>

@property (weak, nonatomic) IBOutlet UISlider *sliderSeek;
@property (weak, nonatomic) IBOutlet UILabel *txtSongName;
@property (weak, nonatomic) IBOutlet UILabel *txtSigerName;

@property (weak, nonatomic) IBOutlet UILabel *txtDuration;
@property (weak, nonatomic) IBOutlet UILabel *txtcurrentTime;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet UIView *lyricView;
@property (weak, nonatomic) IBOutlet UITextView *txtLyric;
@property (weak, nonatomic) IBOutlet MPVolumeView *systemVolume;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UISlider *sliderVolume;

- (id)initWithID:(NSNumber*)ID;

- (IBAction)click_play:(id)sender;
- (IBAction)click_next:(id)sender;
- (IBAction)click_back:(id)sender;

- (IBAction)volumeChanged:(id)sender;

- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
@end
