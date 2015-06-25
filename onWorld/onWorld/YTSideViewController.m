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
#import "PDKeychainBindings.h"
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
    
    int selectedCategoryID;
    int selectedProviderID;
}
@end

@implementation YTSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrMenu = [[NSMutableArray alloc]init];
    selectedProviderID = -1; // all
    selectedCategoryID = -1; //
    NSDictionary *userMenu = nil;
    if([NETWORK_MANAGER isLogin]) {
        userMenu = @{@"Home": @[MENU_INFO,MENU_LOGOUT,MENU_HOME,MENU_SEARCH]};
    }else {
        userMenu = @{@"Home": @[MENU_LOGIN,MENU_HOME,MENU_SEARCH]};
    }

    [arrMenu addObject:userMenu];
    NSArray *providers = [YTProvider MR_findAllSortedBy:@"provID" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];

    if(providers.count > 0){
        NSMutableArray * arrProvider = [NSMutableArray array];
        for (YTProvider *provider in providers) {
            [arrProvider addObject:@{@"id":provider.provID,@"name":provider.provName}];
        }
        [arrMenu addObject:@{@"providers":arrProvider}];
    }
    
    NSArray *categories = [YTCategory MR_findAllSortedBy:@"cateID" ascending:YES inContext:[NSManagedObjectContext MR_defaultContext]];
    if(categories.count >0) {
        NSMutableArray *arrCate = [NSMutableArray array];
        for (YTCategory *category in categories) {
            [arrCate addObject:@{@"id":category.cateID,@"name":category.name}];
        }
        [arrMenu addObject:@{@"categories":arrCate}];
    }
    [self.tbvSideMenu setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

}

- (void)viewDidAppear:(BOOL)animated {
    if([NETWORK_MANAGER isLogin]) {
        NSDictionary *userMenu = @{@"Home": @[MENU_INFO,MENU_LOGOUT,MENU_HOME,MENU_SEARCH]};
        [arrMenu replaceObjectAtIndex:0 withObject:userMenu];
        [self.tbvSideMenu reloadData];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
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
    
    if(indexPath.section == 0) {
        NSString * title = menuContent[indexPath.row];
        if([title isEqualToString:MENU_LOGIN]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"login"]];
        }else if([title isEqualToString:MENU_HOME]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"home"]];
        }else if ([title isEqualToString:MENU_SEARCH]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"search"]];
        }else if([title isEqualToString:MENU_INFO]) {
            [viewCell.imgMenu setImage:[UIImage imageNamed:@"user"]];
            title = [[NSUserDefaults standardUserDefaults]objectForKey:USERNAME];
            [viewCell.txtMenuTitle setTextColor:[UIColor whiteColor]];
        }
         [viewCell.txtMenuTitle setText:title];
    }else {
        NSString *title = [menuContent[indexPath.row] valueForKey:@"name"];
        if(indexPath.section == 1){
            if(selectedProviderID == [[menuContent[indexPath.row] valueForKey:@"id"] intValue]) {
                [viewCell.imgMenu setImage:[UIImage imageNamed:@"circle_checked"]];
            }else {
                [viewCell.imgMenu setImage:[UIImage imageNamed:@"circle"]];
            }
        }else if(indexPath.section == 2) {
            NSString *stringWithoutSpaces = [title
                                             stringByReplacingOccurrencesOfString:@" "
                                             withString:@""].lowercaseString;
            [viewCell.imgMenu setImage:[UIImage imageNamed:stringWithoutSpaces]];
            
        }
        viewCell.txtMenuTitle.text = title;
    }
    return viewCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict = [arrMenu objectAtIndex:indexPath.section];
    NSArray *menus = [dict valueForKey:[dict.allKeys objectAtIndex:0]];
    
    if(indexPath.section == 0) {
        if([menus[indexPath.row] isEqualToString:MENU_LOGIN]) {
            
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            YTLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
            UINavigationController *navCtrll =(UINavigationController*) [self.revealViewController frontViewController];
            [navCtrll pushViewController:loginViewController animated:YES];
            
        }else if ([menus[indexPath.row] isEqualToString:MENU_HOME]) {
            
        }else if ([menus[indexPath.row] isEqualToString:MENU_INFO]) {
            
        }else if ([menus[indexPath.row] isEqualToString:MENU_LOGOUT]) {
            
            [NETWORK_MANAGER logoutWithSuccessBlock:^(AFHTTPRequestOperation *operation, id response) {
               
                [[PDKeychainBindings sharedKeychainBindings]removeObjectForKey:USERNAME];
                [[PDKeychainBindings sharedKeychainBindings]removeObjectForKey:PASSWORD];
                [NETWORK_MANAGER clearData];
                
            } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
        }else if([menus[indexPath.row] isEqualToString:MENU_SEARCH]) {
            
        }
        
    }else if(indexPath.section == 1){
        selectedProviderID = [[menus[indexPath.row] valueForKey:@"id"] intValue];
    }else if (indexPath.section == 2) {
        selectedProviderID = [[menus[indexPath.row] valueForKey:@"id"] intValue];
    }
}

@end
