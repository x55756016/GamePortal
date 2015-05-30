//
//  VipTableViewController.m
//  h5
//
//  Created by wwj on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "VipTableViewController.h"
#import "HomeInfoViewController.h"
#import "h5kkContants.h"
#import "KKUtility.h"
@interface VipTableViewController ()

@end

@implementation VipTableViewController

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
        return 3;
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
            cell = self.helpCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.privilegesCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.onlineCell;
        }
        if(indexPath.row == 2)
        {
            cell = self.activitiesCell;
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
    NSInteger indexSection = indexPath.section;
    NSInteger indexRow=indexPath.row;
    NSString *webUrl=@"";
    if(indexSection==0)
    {
        //设置－帮助
        webUrl=KKWeb_Helper;
    }
    if(indexSection==1)
    {
        if(indexRow==0)
        {  //会员－会员等级
             webUrl=KKWeb_VipLevel  ;
        }
        if(indexRow==1)
        {
            //在线商店
            return;
        }
        if(indexRow==2)
        {
            //会员－会员活动
             webUrl=KKWeb_VipActive;
        }
    }
    if(indexSection==2)
    {
        //成为会员
        [KKUtility justAlert:@"暂未开放"];
        return;
    }
    NSDictionary *adDic=[NSDictionary dictionaryWithObjectsAndKeys:
                             webUrl,@"Url",nil ];
    NSLog(@"打开网页[%@]", adDic);
    [self performSegueWithIdentifier:@"StartWebInfoSegue" sender:adDic];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"StartWebInfoSegue"])
    {
        HomeInfoViewController *gwvc = (HomeInfoViewController *)[segue destinationViewController];
        gwvc.WebInfoDict = (NSDictionary *)sender;
    }
    
}

@end












