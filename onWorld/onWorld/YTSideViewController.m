//
//  YTSideViewController.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTSideViewController.h"
#import "YTSideViewCell.h"
#import "YTSideHeaderViewCell.h"
#import "SWRevealViewController.h"
#import "YTLoginViewController.h"

static const NSString * kYTMenuHome = @"HOME";
static const NSString * kYTMenuLogin = @"LOGIN";
static const NSString * kYTSearch = @"SEARCH";

#define MENU_HOME	@"HOME"
#define MENU_SEARCH	@"SEARCH"
#define MENU_LOGIN	@"LOGIN"
#define MENU_LOGOUT	@"LOGOUT"
#define MENU_INFO	@"INFO"

@interface YTSideViewController ()
{
    NSMutableArray *arrMenu;
}
@end

@implementation YTSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrMenu = [[NSMutableArray alloc]init];
    
    
    [_tbvSideMenu setBackgroundColor:[UIColor blueColor]];
    
    NSDictionary *userMenu = @{@"Home": @[MENU_LOGIN,MENU_HOME,MENU_SEARCH]};
    [arrMenu addObject:userMenu];
//    NSArray *categories =[YTCategory MR_findAll];
//    NSArray *providers = [YTProvider MR_findAll];
//    [arrMenu addObject:@{@"providers":providers}];
//    [arrMenu addObject:@{@"Categories": categories}];
    
    [arrMenu addObject:@{@"providers":@[@"Provider 1",@"Provider 2",@"Provider 3"]}];
    [arrMenu addObject:@{@"Categories":@[@"Category 1",@"Category 2",@"Category 3"]}];
    
    
    
    
    [self.tbvSideMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
   
    return arrMenu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Returan the number of rows in the section.
    NSDictionary *dict = [arrMenu objectAtIndex:section];
    NSArray *list =[dict valueForKey:dict.allKeys[0]];
    return list.count;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    static CGFloat kMenuHeaderHeight = 30.0f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        kMenuHeaderHeight = 40.0f;
    else
        kMenuHeaderHeight = 40.0f;
    return kMenuHeaderHeight;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
    if(section == 0)
        return nil;
    YTSideHeaderViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"headercell"];
    if(headerCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([YTSideHeaderViewCell class]) owner:self options:nil];
        headerCell = [nib objectAtIndex:0];
    }
    
    NSString *title = [[arrMenu[section] allKeys] objectAtIndex:0] ;
    [headerCell.txtHeaderTitle setText:title];
    return headerCell;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YTSideViewCell * viewCell = (YTSideViewCell*)[self.tbvSideMenu dequeueReusableCellWithIdentifier:@"menucell"];
    if (viewCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YTSideViewCell" owner:self options:nil];
        viewCell = [nib objectAtIndex:0];
    }
    NSDictionary *menuDict= [arrMenu objectAtIndex:indexPath.section];
    NSArray *menuContent = [menuDict valueForKey:menuDict.allKeys[0]];
    NSString * title = menuContent[indexPath.row];
    
    if(indexPath.section == 0) {
        if([title isEqualToString:MENU_LOGIN]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"login"]];
        }else if([title isEqualToString:MENU_HOME]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"home"]];
        }else if ([title isEqualToString:MENU_SEARCH]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"search"]];
        }
    }
    CGRect line = CGRectMake(viewCell.txtMenuTitle.frame.origin.x, viewCell.frame.size.height, viewCell.frame.size.width, 1);
    UIView *lineView =[[UIView alloc]initWithFrame:line];
    [lineView setBackgroundColor:[UIColor darkGrayColor]];
    [viewCell addSubview:lineView];
    [viewCell.txtMenuTitle setText:title];
    
    return viewCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            YTLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
            UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
            [navCtrll pushViewController:loginViewController animated:YES];
        }else if (indexPath.row == 1) {
            
        }else if (indexPath.row == 2) {
            
        }
        
    }else {
        
    }
    
    
}

@end
