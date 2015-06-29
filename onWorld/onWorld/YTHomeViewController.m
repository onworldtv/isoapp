//
//  YTCollectionView.m
//  OnWorld
//
//  Created by yestech1 on 6/25/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTHomeViewController.h"
#import "YTGridViewController.h"
@interface YTHomeViewController ()
{
    NSMutableArray *viewControllers;
    NSInteger selectedIndex;
    UIButton * buttonSelected;
}
@end


@implementation YTHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if(viewControllers.count > 0) {
        [self loadTabView];
    }else {
        _btnPopular.enabled = NO;
        _btnRecent.enabled = NO;
        _btnRecomemdation.enabled = NO;
    }
    
//    _tabView.layer.borderWidth = 1.0f;
//    _tabView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
    //
    _btnPopular.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnPopular.layer.borderWidth = 1.0f;
    
    _btnRecent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _btnRecent.layer.borderWidth = 1.0f;
    
    _btnRecomemdation.layer.borderColor = [UIColor blueColor].CGColor;
    _btnRecomemdation.layer.borderWidth = 1.0f;
    
}


- (void)loadTabView {
    NSUInteger lastIndex = selectedIndex;
    selectedIndex = NSNotFound;
    [self handleSelectedButton];
    [self setSelectedIndex:lastIndex];

}

- (void)parentDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    YTGridViewController *currentCtrl = (YTGridViewController *)self.selectedViewController;
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        [currentCtrl setNumberItem:2];
    } else {
        [currentCtrl setNumberItem:3];
    }
}


- (void)handleSelectedButton {
    if(selectedIndex == 0) {
         _btnRecomemdation.layer.borderColor = [UIColor blueColor].CGColor;
        _btnPopular.layer.borderColor = [UIColor darkGrayColor].CGColor;
         _btnRecent.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }else if(selectedIndex == 1) {
         _btnRecomemdation.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _btnRecent.layer.borderColor = [UIColor blueColor].CGColor;
         _btnPopular.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }else if (selectedIndex == 2) {
         _btnRecomemdation.layer.borderColor = [UIColor darkGrayColor].CGColor;
         _btnRecent.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _btnPopular.layer.borderColor = [UIColor blueColor].CGColor;
    }
   
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}



- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated
{
    
    if (![self isViewLoaded])
    {
        selectedIndex = newSelectedIndex;
    }
    else if (selectedIndex != newSelectedIndex)
    {
        UIViewController *fromViewController;
        UIViewController *toViewController;
        
        if (selectedIndex != NSNotFound)
        {

            fromViewController = self.selectedViewController;
        }
        
        NSUInteger oldSelectedIndex = selectedIndex;
        selectedIndex = newSelectedIndex;
        
        if (selectedIndex != NSNotFound)
        {
            toViewController = self.selectedViewController;
        }
        
        if (toViewController == nil)  // don't animate
        {
            [fromViewController.view removeFromSuperview];
        }
        else if (fromViewController == nil)  // don't animate
        {
            toViewController.view.frame = _containerView.bounds;
            [_containerView addSubview:toViewController.view];
        }
        else if (animated)
        {
            CGRect rect = _containerView.bounds;
            if (oldSelectedIndex < newSelectedIndex)
                rect.origin.x = rect.size.width;
            else
                rect.origin.x = -rect.size.width;
            
            toViewController.view.frame = rect;
            
            [self transitionFromViewController:fromViewController
                              toViewController:toViewController
                                      duration:0.3f
                                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                                    animations:^
             {
                 CGRect rect = fromViewController.view.frame;
                 if (oldSelectedIndex < newSelectedIndex)
                     rect.origin.x = -rect.size.width;
                 else
                     rect.origin.x = rect.size.width;
                 
                 fromViewController.view.frame = rect;
                 toViewController.view.frame = _containerView.bounds;
             }
                                    completion:^(BOOL finished)
             {
                 _tabView.userInteractionEnabled = YES;
             }];
        }
        else  // not animated
        {
            [fromViewController.view removeFromSuperview];
            toViewController.view.frame = _containerView.bounds;
            [_containerView addSubview:toViewController.view];
        }
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers {
    UIViewController *oldSelectedViewController = _selectedViewController;
    // Remove the old child view controllers.
    for (UIViewController *viewController in viewControllers)
    {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
    }
    viewControllers = [newViewControllers copy];
    // This follows the same rules as UITabBarController for trying to
    // re-select the previously selected view controller.
    NSUInteger newIndex = [viewControllers indexOfObject:oldSelectedViewController];
    if (newIndex != NSNotFound)
        selectedIndex = newIndex;
    else if (newIndex < [viewControllers count])
        selectedIndex = newIndex;
    else
        selectedIndex = 0;
    // Add the new child view controllers.
    for (UIViewController *viewController in viewControllers)
    {
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
    [self loadTabView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSelectedIndex:(NSUInteger)index {
    
    [self setSelectedIndex:index animated:NO];
}

- (UIViewController *)selectedViewController {
    if (selectedIndex != NSNotFound)
        return (viewControllers)[selectedIndex];
    else
        return nil;
}



- (IBAction)click_recommendation:(id)sender {
    [self setSelectedIndex:0 animated:YES];
    [self handleSelectedButton];
}

- (IBAction)click_recent:(id)sender {
    [self setSelectedIndex:1 animated:YES];
    [self handleSelectedButton];
}

- (IBAction)click_popular:(id)sender {
    [self setSelectedIndex:2 animated:YES];
    [self handleSelectedButton];
}
@end
