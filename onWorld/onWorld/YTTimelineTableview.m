//
//  YTTimelineTableview.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTTimelineTableview.h"
#import "YTTimelineViewCell.h"
#import "YTPlayerViewController.h"
@interface YTTimelineTableview ()
{
    id<YTSelectedItemProtocol>m_delegate;
}
@end

@implementation YTTimelineTableview

- (id)initWithContent:(NSArray *)array delegate:(id<YTSelectedItemProtocol>)delegate  {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        _contentItems = [[NSMutableArray alloc]initWithArray:array];
        m_delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"YTTimelineViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"cellIdentify"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setContentItems:(NSMutableArray *)contentItems {
    _contentItems = contentItems;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentItems.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = _contentItems[indexPath.row];
    YTTimeline *timeline = _contentItems[indexPath.row];
    if(timeline.arrayTimeline) {
        item = [NSKeyedUnarchiver unarchiveObjectWithData:timeline.arrayTimeline];
    }
    YTTimelineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentify" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[YTTimelineViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentify"];
    }
    cell.avartar.layer.borderWidth = 3.0f;
    cell.avartar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.avartar.layer.cornerRadius = cell.avartar.frame.size.width / 2;
    cell.avartar.clipsToBounds = YES;
    cell.txtContentName.text = [item valueForKey:@"name"];
    
    [cell.avartar sd_setImageWithURL:[NSURL URLWithString:item[@"image"]]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    cell.txtSinger.text = @"";
    cell.txtTimeline.text = [NSString stringWithFormat:@"%f - %f",[[item valueForKey:@"start"] floatValue],[[item valueForKey:@"end"] floatValue]];
    
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([m_delegate respondsToSelector:@selector(playItemWithCategoryId:scheduleInded:timelineIndex:)]) {
        [m_delegate playItemWithCategoryId:nil scheduleInded:0 timelineIndex:indexPath.row];
    }
   
}






@end
