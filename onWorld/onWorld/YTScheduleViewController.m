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
}
@end

@implementation YTScheduleViewController



- (id)initWithArray:(NSArray *)array delegate:(id<DelegateSelectedScheduleItem>)delegate{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        arraySchedule = array;
        listTimeline = [[NSArray alloc]init];
        index = 0;
        m_delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    
    self.backEndView.layer.borderColor = [UIColor colorWithHexString:@"#dfdfdf"].CGColor;
    self.backEndView.layer.borderWidth = 0.5;
    if(arraySchedule.count >0) {
        YTTimeline *timeline = arraySchedule[index];
        if(timeline.arrayTimeline) {
            listTimeline = [NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline];
        }
        [self addScheduleButton];
    }
    
}


- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSArray *subViews = [self.topView subviews];
    int i= 0;
    int delta = self.topView.frame.size.width / subViews.count;
    for(UIButton *btnSchedule in subViews) {
        
        CGRect frame = CGRectMake(i*delta+1,0, delta, 35);
        [btnSchedule setFrame:frame];
        i++;
    }
    
}



- (void)addScheduleButton {
    if(arraySchedule.count >0) {
        
        buttons = [NSMutableArray array];
        int width = self.topView.frame.size.width;
        int delta = width/3;
        for(int i=0;i<arraySchedule.count;i++) {
            if(i > 2) {
                return ;
            }
            YTTimeline *timeline = arraySchedule[i];
            UIButton *btnTimeline = [UIButton buttonWithType:UIButtonTypeSystem];
            [btnTimeline setTitle:timeline.title forState:UIControlStateNormal];
            
            [btnTimeline setFrame:CGRectMake(delta * i + 1, 0, 100, 35)];
            [btnTimeline setTag:i];
            [btnTimeline addTarget:self
                            action:@selector(click_scheduleButton:)
                  forControlEvents:UIControlEventTouchDown];
            if(i== index) {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:17]];
                [btnTimeline setTitleColor:[UIColor colorWithHexString:@"#5EA2FD"] forState:UIControlStateNormal];
                btnTimeline.layer.borderWidth = 0.5f;
                btnTimeline.layer.borderColor = [UIColor colorWithHexString:@"5ea2fd"].CGColor;
                
            }else {
                [btnTimeline.titleLabel setFont:[UIFont fontWithName:@"UTM BEBAS" size:17]];
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
    
    [sender setTitleColor: [UIColor colorWithHexString:@"#5EA2FD"] forState:UIControlStateNormal];
    sender.layer.borderWidth = 0.5f;
    sender.layer.borderColor = [UIColor colorWithHexString:@"#5EA2FD"].CGColor;
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
    
    /*
     name	:	Bird Nest Collagen
     image	:	http://img.onworldtv.com/wxh/timeline/2015/04/07/510768-ITV-homeshopping.jpg
     description	:
     link	:	http://204.9.200.244/sata/itv/Bird.Nest.Collagen.720p/index.m3u8
     start	:	00:00:00
     end	:	00:02:30
     */
    
    viewCell.txtContentName.text = [timeDic valueForKey:@"name"];
    viewCell.txtTimeline.text = [NSString stringWithFormat:@"%@ - %@",[timeDic valueForKey:@"start"],[timeDic valueForKey:@"end"]];
    viewCell.txtSinger.text = [timeDic valueForKey:@"description"];
    __weak UIImageView *imageView = viewCell.avartar;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[timeDic valueForKey:@"image"] completed:^(NSError *error, UIImage *image) {
        [imageView setImage:image];
    }];
    
    return viewCell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([m_delegate respondsToSelector:@selector(delegateSelectedScheduleItemWithIndexSchedule:indexTimeline:)]) {
        [m_delegate delegateSelectedScheduleItemWithIndexSchedule:index indexTimeline:indexPath.row];
    }
}

@end
