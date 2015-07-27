//
//  YTChromcastDeviceViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTDeviceViewController.h"

@interface YTDeviceViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation YTDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return _chromecastController.deviceScanner.devices.count;
    return [[CHROMCAST_MANAGER.chromcastCtrl deviceScanner]devices].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForChromecast = @"chromecast";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdForChromecast];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdForChromecast];
    }
    
    // Configure the cell...
    GCKDevice *device = [[CHROMCAST_MANAGER.chromcastCtrl deviceScanner].devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.friendlyName;
    cell.detailTextLabel.text = device.modelName;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSLog(@"Device %ld: %@", (long)indexPath.row, device.friendlyName);
    
    if ([CHROMCAST_MANAGER.chromcastCtrl isConnected] && [CHROMCAST_MANAGER.chromcastCtrl deviceManager].device == device) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSLog(@"connected");
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    // clear the selection
    for (int i = 0; i < CHROMCAST_MANAGER.chromcastCtrl.deviceScanner.devices.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        if (cell == selectedCell) {
            if (cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
               
                GCKDevice *device = [CHROMCAST_MANAGER.chromcastCtrl.deviceScanner.devices objectAtIndex:indexPath.row];
                [CHROMCAST_MANAGER.chromcastCtrl connectToDevice:device];
            }
            else {
                //cell.accessoryType = UITableViewCellAccessoryNone;
                [CHROMCAST_MANAGER.chromcastCtrl stopCastMedia];
                [CHROMCAST_MANAGER.chromcastCtrl disconnectFromDevice];
            }
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didDiscoverDeviceOnNetwork
{
    [self.tableView reloadData];
}
@end
