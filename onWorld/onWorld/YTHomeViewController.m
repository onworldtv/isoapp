//
//  YTCollectionView.m
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTHomeViewController.h"

@interface YTHomeViewController ()
{
    NSMutableArray *viewControllers;
    NSInteger selectedIndex;
    UIViewController *selectedViewController;
}
@end


@implementation YTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedIndex = 0;
    selectedViewController = nil;
    
    if(viewControllers.count > 0) {
        
        selectedViewController = viewControllers[selectedIndex];
        if(selectedViewController) {
            selectedViewController.view.frame = _containerView.bounds;
            [self.view addSubview:selectedViewController.view];
        }else {
            _btnPopular.enabled = NO;
            _btnRecent.enabled = NO;
            _btnRecomemdation.enabled = NO;
        }
        
    }else {
        _btnPopular.enabled = NO;
        _btnRecent.enabled = NO;
        _btnRecomemdation.enabled = NO;
    }
        
    
    // Do any additional setup after loading the view from its nib.
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    [self setSelectedIndex:selectedIndex animated:NO];
}

-(void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    
    if (![self isViewLoaded])
    {
        selectedIndex = newSelectedIndex;
    }
    else if (selectedIndex != newSelectedIndex) {
        
        UIViewController *fromViewController;
        UIViewController *toViewController;
        if (selectedIndex != NSNotFound)
        {
            fromViewController = selectedViewController;
        }
        NSUInteger oldSelectedIndex = selectedIndex;
        selectedIndex = newSelectedIndex;
        
        if (selectedIndex != NSNotFound)
        {
            
            toViewController = viewControllers[selectedIndex];
        }
        
        if (toViewController == nil){
            [fromViewController.view removeFromSuperview];
        }
        else if (fromViewController == nil){
            
            toViewController.view.frame = _containerView.bounds;
            [_containerView addSubview:toViewController.view];
            
        }else if (animated){
            CGRect rect = _containerView.bounds;
            if (oldSelectedIndex < newSelectedIndex)
                rect.origin.x = rect.size.width;
            else
                rect.origin.x = -rect.size.width;
            
            toViewController.view.frame = rect;
            
            [self transitionFromViewController:fromViewController
                              toViewController:toViewController
                                      duration:0.1f
                                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                                    animations:^{
                                        CGRect rect = fromViewController.view.frame;
                                        if (oldSelectedIndex < newSelectedIndex)
                                            rect.origin.x = -rect.size.width;
                                        else
                                            rect.origin.x = rect.size.width;
                                        fromViewController.view.frame = rect;
                                        toViewController.view.frame = _containerView.bounds;
                                        
                                    }completion:^(BOOL finished){
                                        NSLog(@"");
                                        
                                    }];
        }else {
            selectedViewController = toViewController;
            
            selectedViewController.view.frame = _containerView.bounds;
            [_containerView addSubview:toViewController.view];
            
        }
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)click_recommendation:(id)sender {
}

- (IBAction)click_recent:(id)sender {
}

- (IBAction)click_popular:(id)sender {
}
@end
