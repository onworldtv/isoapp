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
    YTContent *content;
}
@end

@implementation YTDetailViewController


- (id)init {
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(_contentID > 0) {
        [self performSelectorOnMainThread:@selector(bindingData) withObject:nil waitUntilDone:NO];
    }
}


- (void)setContentID:(int)contentID {
    _contentID = contentID;
    [self performSelectorOnMainThread:@selector(bindingData) withObject:nil waitUntilDone:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)bindingData {
    content = [YTContent MR_findFirstByAttribute:@"contentID" withValue:@(_contentID)];
    if(content) {
        _txtGenre.text = content.gen.genName;
        _txtNational.text = content.detail.country.name;
        _txtDuration.text  =  [NSString stringWithFormat:@"%f",content.detail.duration.floatValue];
        _lbDescription.text = content.desc;
        _txtContentName.text = content.name;
        __weak UIImageView *imageView = _imgBanner;
        [[DLImageLoader sharedInstance]loadImageFromUrl:content.image completed:^(NSError *error, UIImage *image) {
            [imageView setImage:image];
        }];
    }
}

- (IBAction)click_player:(id)sender {
    
    if([_delegate respondsToSelector:@selector(delegatePlayitem:)] && content) {
        [_delegate delegatePlayitem:content.contentID.intValue];
    }

}
- (IBAction)click_show:(id)sender {
    
}
@end
