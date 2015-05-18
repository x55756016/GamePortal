//
//  AccountTableViewController.m
//  h5
//
//  Created by wwj on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "AccountTableViewController.h"

@interface AccountTableViewController ()

@end

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------------UITableViewDataSource-----------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    
    else if(section == 1)
    {
        return 2;
    }
    
    else if(section == 2)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell = self.accountCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.KCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.rankCell;
        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.becomeVipCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end



















