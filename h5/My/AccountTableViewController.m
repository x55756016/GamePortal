//
//  AccountTableViewController.m
//  h5
//
//  Created by wwj on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "AccountTableViewController.h"
#import "KKUtility.h"

@interface AccountTableViewController (){
 NSDictionary *MyInfo;
}
@end

@implementation AccountTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyInfo=[KKUtility getUserInfoFromLocalFile];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
//     NSString *useridStr = [NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"UserId"]];
     NSString *userMobile = [NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"Mobile"]];
    [self.UserIdLabel setText:userMobile];
    
     NSString *kCoin = [NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"Money"]];
    [self.kCoinLabel setText:kCoin];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    MyInfo=[KKUtility getUserInfoFromLocalFile];
    NSString *kCoin = [NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"Money"]];
    [self.kCoinLabel setText:kCoin];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [super viewWillAppear:YES];
}

//-----------------------UITableViewDataSource-----------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
    }
    
    else if(section == 1)
    {
        return 1;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger Sectionindex=indexPath.section;
    NSInteger rowNumber=indexPath.row;
    if(Sectionindex==0)
    {
        if(rowNumber!=1)
        {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    }
}
//

@end



















