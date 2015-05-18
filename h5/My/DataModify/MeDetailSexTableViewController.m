//
//  MeDetailSexTableViewController.m
//  ooz
//
//  Created by wwj on 14-5-8.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import "MeDetailSexTableViewController.h"

@interface MeDetailSexTableViewController ()
@end

@implementation MeDetailSexTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0)
    {
        cell = self.manTableViewCell;
        
        if([self.sexSegueString isEqualToString:@"0"])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    if(indexPath.row == 1)
    {
        cell = self.womanTableViewCell;
        
        if([self.sexSegueString isEqualToString:@"1"])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        self.manTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.womanTableViewCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.sexSegueString = @"0";
        [self.MDSTVCdelegate meDetailSexTableViewControllerSave:self];
    }
    
    if(indexPath.row == 1)
    {
        self.womanTableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.manTableViewCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.sexSegueString = @"1";
        [self.MDSTVCdelegate meDetailSexTableViewControllerSave:self];
    }
}

@end










