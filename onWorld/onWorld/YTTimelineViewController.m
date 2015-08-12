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
    YTContent *contentObj;
    NSMutableArray *viewControllers;
    NSInteger selectedIndex;
    YTTimelineTableview *m_timelineViewController;
    YTEpisodesViewController *m_episodesViewController;
    NSMutableArray *listButton;
    int index;
    NSMutableArray *tabItemTitle;
    NSInteger m_tag;
    id<YTSelectedItemProtocol> m_delegate;
}
@end

@implementation YTTimelineViewController


- (id)initWithContent:(YTContent*)content delegate:(id<YTSelectedItemProtocol>)delegate tableTag:(NSInteger)tag{
    self =[super initWithNibName:NSStringFromClass(self.class) bundle:nil]; {
        contentObj = content;
        index = 0;
        m_delegate = delegate;
        m_tag = tag;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tabItemTitle = [NSMutableArray array];
    
    self.tabView.backgroundColor = [UIColor clearColor];
    
    viewControllers = [NSMutableArray array];
    _tabView.layer.borderWidth = 0.5f;
    _tabView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
    if(contentObj.detail.timeline.allObjects.count >0) {
        m_timelineViewController = [[YTTimelineTableview alloc]initWithContent:contentObj.detail.timeline.allObjects delegate:m_delegate tag:m_tag contentID:contentObj.contentID];
        [viewControllers addObject:m_timelineViewController];
        [tabItemTitle addObject:@"TIMELINE"];
    }
    if(contentObj.detail.episode.allObjects.count >0) {
        m_episodesViewController = [[YTEpisodesViewController alloc]initWithContent:contentObj.detail.episode.allObjects
                                                                           detailID:contentObj.contentID
                                                                           delegate:m_delegate
                                                                           tableTag:m_tag];
        [viewControllers addObject:m_episodesViewController];
        [tabItemTitle addObject:@"EPISODES"];
    }
    if(viewControllers.count > 0) {
        [self addScheduleButton];
        [self setup];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    
    NSArray *subViews = [self.tabViewContainer subviews];
    int i= 0;
    int delta = self.tabViewContainer.frame.size.width / subViews.count;
    for(UIButton *tabItem in subViews) {
        
        CGRect frame = CGRectMake(i*delta,0, delta, 35);
        [tabItem setFrame:frame];
        i++;
    }

}
- (void)addScheduleButton {

    if(viewControllers.count >0) {
        
        listButton = [NSMutableArray array];
        int width = self.tabView.frame.size.width;
        int delta = width/viewControllers.count;
        
        if(viewControllers.count == 1) {
            if(m_tag == 1) {
                [self.tabView setBackgroundColor:[UIColor clearColor]];
                self.tabView.layer.borderWidth= 0.5f;
                self.tabView.layer.borderColor = [UIColor whiteColor].CGColor;
            }else {
                [self.tabView setBackgroundColor:[UIColor colorWithHexString:@"#5EA2FD"]];
                self.tabView.layer.borderWidth= 0.0f;
            }
            UIButton *btnTimeline = [UIButton buttonWithType:UIButtonTypeSystem];
            [btnTimeline setTitle:tabItemTitle[0] forState:UIControlStateNormal];
            [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:21]];
            [btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnTimeline setFrame:CGRectMake(0, 0, delta, 35)];
            [self.tabViewContainer addSubview:btnTimeline];
        }else {
            for(int i=0;i<viewControllers.count;i++) {
                UIButton *btnTimeline = [UIButton buttonWithType:UIButtonTypeSystem];
                [btnTimeline setTitle:tabItemTitle[i] forState:UIControlStateNormal];
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:21]];
                [btnTimeline setFrame:CGRectMake(delta * i, 0, delta, 35)];
                [btnTimeline setTag:i];
                if(viewControllers.count > 0) {
                    [btnTimeline addTarget:self
                                    action:@selector(click_tabView:)
                          forControlEvents:UIControlEventTouchDown];
                }
                if(i== index) {
                    [btnTimeline setTitleColor:[UIColor colorWithHexString:@"#5EA2FD"] forState:UIControlStateNormal];
                    btnTimeline.layer.borderWidth = 0.5f;
                    btnTimeline.layer.borderColor = [UIColor colorWithHexString:@"5ea2fd"].CGColor;
                    
                }else {
                    [btnTimeline setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                }
                [listButton addObject:btnTimeline];
                [self.tabViewContainer addSubview:btnTimeline];
            }
        }
    }
}


- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    NSArray *subViews = [self.tabViewContainer subviews];
    int i= 0;
    int delta = self.tabViewContainer.frame.size.width / subViews.count;
    for(UIButton *tabItem in subViews) {
        CGRect frame = CGRectMake(i*delta,0, delta, 35);
        [tabItem setFrame:frame];
        i++;
    }
}

- (void)click_tabView:(UIButton *)sender {
    UIButton *previouButton = listButton[index];
    [previouButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    previouButton.layer.borderWidth =0;
    
    [sender setTitleColor: [UIColor colorWithHexString:@"#5EA2FD"] forState:UIControlStateNormal];
    sender.layer.borderWidth = 0.5f;
    sender.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
    index = (int)sender.tag;
    
    [self setSelectedIndex:sender.tag animated:YES];
    
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
    [self setSelectedIndex:lastIndex];
    
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

-(void)setSelectedIndex:(NSUInteger)indexPath {
    
    [self setSelectedIndex:indexPath animated:NO];
}

- (UIViewController *)selectedViewController {
    if (selectedIndex != NSNotFound)
        return (viewControllers)[selectedIndex];
    else
        return nil;
}


@end
