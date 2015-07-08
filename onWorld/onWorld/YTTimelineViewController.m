//
//  YTTimelineViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTTimelineViewController.h"
#import "YTTimelineTableview.h"
#import "YTEpisodesViewController.h"
@interface YTTimelineViewController ()
{
    NSMutableArray *viewControllers;
    NSInteger selectedIndex;
    YTTimelineTableview *m_timelineViewController;
    YTEpisodesViewController *m_episodesViewController;
}
@end

@implementation YTTimelineViewController


- (id)init {
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil]; {
        m_timelineViewController = [[YTTimelineTableview alloc]initWithStyle:UITableViewStylePlain];
        m_episodesViewController = [[YTEpisodesViewController alloc]initWithStyle:UITableViewStylePlain];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tabView.layer.borderWidth = 1.0f;
    _tabView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    _btnTimeLine.layer.borderColor = [UIColor blueColor].CGColor;
    _btnEpisodes.layer.borderWidth = 1.0f;
    [_btnTimeLine setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self setViewControllers:@[m_timelineViewController,m_episodesViewController]];
    if(viewControllers.count > 0) {
        [self setup];
    }
}

- (void)reload {
    
}

- (void)setContentID:(int)contentID {
    _contentID = contentID;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    NSUInteger lastIndex = selectedIndex;
    selectedIndex = NSNotFound;
    [self buttonSellected];
    [self setSelectedIndex:lastIndex];
    
}
- (void)buttonSellected {
    
    if(selectedIndex == 0) {
        
        _btnTimeLine.layer.borderWidth = 1.0f;
        _btnEpisodes.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
        
        [_btnTimeLine setTitleColor:[UIColor colorWithHexString:@"5EA2FD"] forState:UIControlStateNormal];
        [_btnEpisodes setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        _btnEpisodes.layer.borderWidth = 0;
        
    }else if(selectedIndex == 1) {
        
        
        
        [_btnTimeLine setTitleColor:[UIColor colorWithHexString:@"dfdfdf"] forState:UIControlStateNormal];
        [_btnEpisodes setTitleColor:[UIColor colorWithHexString:@"5EA2FD"] forState:UIControlStateNormal];
        
        _btnTimeLine.layer.borderWidth = 0;
        _btnEpisodes.layer.borderWidth = 1.0f;
    }
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
            toViewController.view.frame = _contentView.bounds;
            [_contentView addSubview:toViewController.view];
        }
        else if (animated)
        {
            CGRect rect = _contentView.bounds;
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
                 toViewController.view.frame = _contentView.bounds;
             }
                                    completion:^(BOOL finished)
             {
                 _tabView.userInteractionEnabled = YES;
             }];
        }
        else  // not animated
        {
            [fromViewController.view removeFromSuperview];
            toViewController.view.frame = _contentView.bounds;
            [_contentView addSubview:toViewController.view];
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
    
//    [self setup];
    
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

- (IBAction)click_episodes:(id)sender {
    [self setSelectedIndex:1 animated:YES];
    [self buttonSellected];
}

- (IBAction)click_timeline:(id)sender {
    [self setSelectedIndex:0 animated:YES];
    [self buttonSellected];
}
@end
