//
//  YTTimelineTableview.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTTimelineTableview.h"
#import "YTTimelineViewCell.h"
@interface YTTimelineTableview ()

@end

@implementation YTTimelineTableview

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self) {
        _contentItems = [[NSMutableArray alloc]init];
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
    return 98;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = _contentItems[indexPath.row];
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
    __weak UIImageView *imageView = cell.avartar;
    [[DLImageLoader sharedInstance]loadImageFromUrl:[item valueForKey:@"image"] completed:^(NSError *error, UIImage *image) {
        [imageView setImage:image];
    }];
    cell.txtSinger.text = @"";
    cell.txtTimeline.text = [NSString stringWithFormat:@"%f - %f",[[item valueForKey:@"start"] floatValue],[[item valueForKey:@"end"] floatValue]];
    
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
