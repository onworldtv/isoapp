//
//  YTChromcastDeviceViewController.m
//  OnWorld
//
//  Created by yestech1 on 7/23/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "YTChromcastDeviceViewController.h"

@interface YTChromcastDeviceViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation YTChromcastDeviceViewController

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

@end
