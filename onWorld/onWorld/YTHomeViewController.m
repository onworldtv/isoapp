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
//        selectedViewController = viewControllers[selectedIndex];
//        if(selectedViewController) {
//            selectedViewController.view.frame = _containerView.bounds;
//            [self.containerView addSubview:selectedViewController.view];
//        }else {
//            _btnPopular.enabled = NO;
//            _btnRecent.enabled = NO;
//            _btnRecomemdation.enabled = NO;
//        }
        
    }else {
        _btnPopular.enabled = NO;
        _btnRecent.enabled = NO;
        _btnRecomemdation.enabled = NO;
    }
        
    
    // Do any additional setup after loading the view from its nib.
}


- (void)loadTabView {
    NSUInteger lastIndex = selectedIndex;
    selectedIndex = NSNotFound;
    [self setSelectedIndex:lastIndex];

}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    YTGridViewController *currentCtrl = (YTGridViewController *)_selectedViewController;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [currentCtrl setSize:CGSizeMake(182, 190) numberItem:3];
    } else {
        [currentCtrl setSize: CGSizeMake(153, 180) numberItem:2];
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
//            UIButton *fromButton = (UIButton *)[tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
//            [self deselectTabButton:fromButton];
            fromViewController = self.selectedViewController;
        }
        
        NSUInteger oldSelectedIndex = selectedIndex;
        selectedIndex = newSelectedIndex;
        
//        UIButton *toButton;
        if (selectedIndex != NSNotFound)
        {
//            toButton = (UIButton *)[tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
//            [self selectTabButton:toButton];
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
//            [self centerIndicatorOnButton:toButton];
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

- (void)setViewControllers:(NSArray *)newViewControllers
{
    NSAssert([newViewControllers count] >= 2, @"MHTabBarController requires at least two view controllers");
    
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSelectedIndex:(NSUInteger)index {
    
    [self setSelectedIndex:index animated:NO];
}

- (UIViewController *)selectedViewController
{
    if (selectedIndex != NSNotFound)
        return (viewControllers)[selectedIndex];
    else
        return nil;
}

/*

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
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)click_recommendation:(id)sender {
    [self setSelectedIndex:0 animated:YES];
}

- (IBAction)click_recent:(id)sender {
    [self setSelectedIndex:1 animated:YES];

}

- (IBAction)click_popular:(id)sender {
    [self setSelectedIndex:2 animated:YES];

}
@end
