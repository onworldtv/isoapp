//
//  YTEpisodesViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/2/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTEpisodesViewController.h"
#import "YTEpisodesViewCell.h"
@interface YTEpisodesViewController () {
    NSNumber *m_detailID;
    id<YTSelectedItemProtocol>m_delegate;
}

@end

@implementation YTEpisodesViewController



- (id)initWithContent:(NSArray *)array detailID:(NSNumber *)detailID delegate:(id<YTSelectedItemProtocol>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    if(self) {
        _contentItems = [[NSMutableArray alloc]initWithArray:array];
        m_detailID = detailID;
        m_delegate = delegate;
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if(self) {
        _contentItems = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register Class for Cell Reuse Identifier
    NSSortDescriptor *sdSortDate = [NSSortDescriptor sortDescriptorWithKey:@"episodesID" ascending:YES];
    _contentItems = [NSMutableArray arrayWithArray:[_contentItems sortedArrayUsingDescriptors:@[sdSortDate]]];
    
    UINib *nib = [UINib nibWithNibName:@"YTEpisodesViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"cellIdentify"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundView:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
     [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contentItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    YTEpisodes *item = _contentItems[indexPath.row];
    YTEpisodesViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cellIdentify"];
    if (!cell)
    {
        cell = [[YTEpisodesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentify"];
    }
    cell.avatar.layer.borderWidth = 3.0f;
    cell.avatar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.avatar.layer.cornerRadius = cell.avatar.frame.size.width / 2;
    cell.avatar.clipsToBounds = YES;
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    if(item.episodesID.intValue == m_detailID.intValue) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition: UITableViewScrollPositionMiddle];
    }
  
    [cell.avatar sd_setImageWithURL:[NSURL URLWithString:item.image]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    cell.txtContentName.text = item.desc;
    cell.txtEpisodes.text = item.name;
    cell.tag = _cellViewTag;
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YTEpisodes *episodes = _contentItems[indexPath.row];
    if([m_delegate respondsToSelector:@selector(delegatePlayitem:)]) {
        [m_delegate delegatePlayitem:episodes.episodesID.intValue];
    }
}



@end
