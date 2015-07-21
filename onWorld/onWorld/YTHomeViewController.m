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
    NSString * m_title;
    NSDictionary *categoryEachViewCtrl;
}
@end


@implementation YTHomeViewController


- (id)initWithTitle:(NSString *)title {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        m_title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if(viewControllers.count > 0) {
        [self loadTabView];
    }else {
        _btnPopular.enabled = NO;
        _btnRecent.enabled = NO;
        _btnRecomemdation.enabled = NO;
    }
    
    _tabView.layer.borderColor = [UIColor colorWithHexString:@"#dfdfdf"].CGColor;
    _tabView.layer.borderWidth = 0.5f;
    _btnRecomemdation.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
    _btnRecomemdation.layer.borderWidth = 0.5f;
    [_txtTitle setText:m_title.uppercaseString];
    
}


- (void)setCategories:(NSDictionary *)categories {
    categoryEachViewCtrl = [NSMutableDictionary dictionaryWithDictionary:categories];
    for (YTGridViewController *viewCtrl in viewControllers) {
        [viewCtrl setContentsView:[categories valueForKey:([viewCtrl identify])]];
    }
}

- (void)loadTabView {
    NSUInteger lastIndex = selectedIndex;
    selectedIndex = NSNotFound;
    [self handleSelectedButton];
    [self setSelectedIndex:lastIndex];

}



- (void)handleSelectedButton {
    if(selectedIndex == 0) {
        
        _btnRecomemdation.layer.borderWidth = 0.5f;
         _btnRecomemdation.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
         [_btnRecomemdation setTitleColor:[UIColor colorWithHexString:@"5EA2FD"] forState:UIControlStateNormal];
         [_btnPopular setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
         [_btnRecent setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        
        
        _btnPopular.layer.borderWidth = 0;
        _btnRecent.layer.borderWidth = 0;
    }else if(selectedIndex == 1) {

        
        
        [_btnRecomemdation setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        [_btnPopular setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        [_btnRecent setTitleColor:[UIColor colorWithHexString:@"5EA2FD"] forState:UIControlStateNormal];
        
        
        _btnRecomemdation.layer.borderWidth = 0;
        _btnRecent.layer.borderWidth = 0.5f;
        _btnRecent.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
        _btnPopular.layer.borderWidth = 0;
        
    }else if (selectedIndex == 2) {
        
        [_btnRecomemdation setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        [_btnPopular setTitleColor:[UIColor colorWithHexString:@"5EA2FD"] forState:UIControlStateNormal];
        [_btnRecent setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        _btnRecomemdation.layer.borderWidth = 0;
        _btnRecent.layer.borderWidth  = 0;
        _btnPopular.layer.borderWidth = 0.5f;
        _btnPopular.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
        
    }
   
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)parentDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation numberItem:(int)numberItem{
    
    YTGridViewController *currentCtrl = (YTGridViewController *)self.selectedViewController;
    [currentCtrl setNumberItem:numberItem];
//    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
//        [currentCtrl setNumberItem:numberItem];
//    } else {
//        [currentCtrl setNumberItem:numberItem+1];
//    }
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


- (IBAction)click_showMore:(id)sender {
    if([_delegate respondsToSelector:@selector(delegateDisplayMoreCategoryMode:)]) {
        [_delegate delegateDisplayMoreCategoryMode:_mode];
    }
}
@end
