//
//  YTDetailViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTDetailViewController.h"
#import "YTPlayerViewController.h"
@interface YTDetailViewController ()
{
    YTContent *contentDetail;
    UIViewController * m_timelineViewCtrl;
}
@end

@implementation YTDetailViewController


- (id)initWithContent:(YTContent*)content {
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        contentDetail = content;
    }
    return self;
}

- (id)initWithContent:(YTContent *)content timelineView:(UIViewController *)timelineCtrl {
    if(![YTOnWorldUtility isIdiomIphone]) { // is ipad
        if(timelineCtrl) {
            self = [super initWithNibName:@"YTDetailViewController_ipad" bundle:nil];
        }else {
            self = [super initWithNibName:@"YTDetailViewController_ipad_2" bundle:nil];
        }
    }else {
        self  = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    }
    
    if(self) {
        contentDetail = content;
        m_timelineViewCtrl = timelineCtrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(contentDetail > 0) {
        [self performSelectorOnMainThread:@selector(bindingData) withObject:nil waitUntilDone:NO];
    }
    if(m_timelineViewCtrl) {
        m_timelineViewCtrl.view.frame = self.timelineView.bounds;
        [m_timelineViewCtrl.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.timelineView addSubview:m_timelineViewCtrl.view];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)bindingData {
    _txtGenre.text = contentDetail.gen.genName;
    _txtNational.text = contentDetail.detail.country.name;
    _txtDuration.text  = [YTOnWorldUtility stringWithTimeInterval:contentDetail.detail.duration.intValue];
    _lbDescription.text = contentDetail.desc;
    _txtContentName.text = contentDetail.name;
    [_imgBanner sd_setImageWithURL:[NSURL URLWithString:contentDetail.image] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

}

- (IBAction)click_player:(id)sender {
    
    if([_delegate respondsToSelector:@selector(delegatePlayItemWithID:)] && contentDetail) {
        [_delegate delegatePlayItemWithID:contentDetail.contentID];
    }
}

@end
