//
//  YTScheduleViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTScheduleViewController.h"
#import "YTTimelineViewCell.h"
@interface YTScheduleViewController () <UITableViewDelegate,UITableViewDataSource>
{
    int index;
    NSArray *listTimeline;
    NSArray *arraySchedule;
    NSMutableArray *buttons;
    id<DelegateSelectedScheduleItem>m_delegate;
    NSInteger cellViewTag;
}
@end

@implementation YTScheduleViewController



- (id)initWithArray:(NSArray *)array delegate:(id<DelegateSelectedScheduleItem>)delegate tag:(NSInteger)tagView {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        arraySchedule = array;
        listTimeline = [[NSArray alloc]init];
        index = 0;
        m_delegate = delegate;
        cellViewTag = tagView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backEndView.layer.borderColor = [UIColor colorWithHexString:@"#dfdfdf"].CGColor;
    self.backEndView.layer.borderWidth = 0.5;
    if(cellViewTag == 1) {
        [self.titleView setBackgroundColor:[UIColor clearColor]];
        self.titleView.hidden = YES;
        self.heightContraint.constant = 0;
    }
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    if(arraySchedule.count >0) {
        YTTimeline *timeline = arraySchedule[index];
        if(timeline.arrayTimeline) {
            listTimeline = [NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline];
        }
        [self addScheduleButton];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];    
    
    NSArray *subViews = [self.topView subviews];
    int i= 0;
    int delta = self.topView.frame.size.width / subViews.count;
    for(UIButton *btnSchedule in subViews) {
        
        CGRect frame = CGRectMake(i*delta,0, delta, 35);
        [btnSchedule setFrame:frame];
        i++;
    }

}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSArray *subViews = [self.topView subviews];
    int i= 0;
    int delta = self.topView.frame.size.width / subViews.count;
    for(UIButton *btnSchedule in subViews) {
        
        CGRect frame = CGRectMake(i*delta,0, delta, 35);
        [btnSchedule setFrame:frame];
        i++;
    }
}

- (void)addScheduleButton {
    if(arraySchedule.count >0) {
        
        buttons = [NSMutableArray array];
        int width = self.topView.frame.size.width;
        int delta = width/arraySchedule.count;
        for(int i=0;i<arraySchedule.count;i++) {
            if(i > 2) {
                return ;
            }
            YTTimeline *timeline = arraySchedule[i];
            UIButton *btnTimeline = [UIButton buttonWithType:UIButtonTypeSystem];
            [btnTimeline setTitle:timeline.title forState:UIControlStateNormal];
            
            [btnTimeline setFrame:CGRectMake(delta * i , 0, delta, 35)];
            [btnTimeline setTag:i];
            [btnTimeline addTarget:self
                            action:@selector(click_scheduleButton:)
                  forControlEvents:UIControlEventTouchDown];
            if(i== index) {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:21]];
                btnTimeline.layer.borderWidth = 0.5f;
                if(cellViewTag == 1) {
                    [btnTimeline setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    btnTimeline.layer.borderColor = [UIColor whiteColor].CGColor;
                }else {
                    [btnTimeline setTitleColor:[UIColor colorWithHexString:@"#5ea2fd"] forState:UIControlStateNormal];
                      btnTimeline.layer.borderColor = [UIColor colorWithHexString:@"5ea2fd"].CGColor;
                }
                
            }else {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:21]];
                [btnTimeline setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
            [buttons addObject:btnTimeline];
            [self.topView addSubview:btnTimeline];
        }
    }
}

- (void)click_scheduleButton:(UIButton *)sender {
    
    UIButton *previouButton = buttons[index];
    [previouButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    previouButton.layer.borderWidth =0;
    sender.layer.borderWidth = 0.5f;
    if(cellViewTag == 1) {
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sender.layer.borderColor = [UIColor whiteColor].CGColor;
    }else {
        [sender setTitleColor: [UIColor colorWithHexString:@"#5EA2FD"] forState:UIControlStateNormal];
        sender.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
    }
    index = sender.tag;
    
    YTTimeline *timeline = arraySchedule[index];
    if(timeline.arrayTimeline) {
        listTimeline = [NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline];
        [UIView transitionWithView:self.tableView
                          duration:0.35f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void){
             
                            [self.tableView reloadData];
                        }completion:nil];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTimeline.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *timeDic = listTimeline[indexPath.row];
    
    YTTimelineViewCell * viewCell = (YTTimelineViewCell*)[tableView dequeueReusableCellWithIdentifier:@"playerTableViewCellIdentify"];
    if (viewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YTTimelineViewCell" owner:self options:nil];
        viewCell = [nib objectAtIndex:0];
    }
    viewCell.avartar.layer.borderWidth = 2.0f;
    viewCell.avartar.layer.borderColor = [UIColor colorWithHexString:@"#c1c1c1"].CGColor;
    viewCell.avartar.layer.cornerRadius = viewCell.avartar.frame.size.width / 2;
    viewCell.avartar.clipsToBounds = YES;
    

    
    viewCell.txtContentName.text = [timeDic valueForKey:@"name"];
    viewCell.txtTimeline.text = [NSString stringWithFormat:@"%@ - %@",[timeDic valueForKey:@"start"],[timeDic valueForKey:@"end"]];
    viewCell.txtSinger.text = [timeDic valueForKey:@"description"];
    
    [viewCell.avartar sd_setImageWithURL:[NSURL URLWithString:timeDic[@"image"]]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    [viewCell setTag:cellViewTag];
    return viewCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([m_delegate respondsToSelector:@selector(delegateSelectedScheduleItemWithIndexSchedule:indexTimeline:)]) {
         NSDictionary *timeDic = listTimeline[indexPath.row];
        [m_delegate delegateSelectedScheduleItemWithIndexSchedule:index indexTimeline:@([timeDic[@"id"] intValue])];
    }
}








@end
