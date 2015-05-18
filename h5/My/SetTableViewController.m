//
//  SetTableViewController.m
//  h5
//
//  Created by hf on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SetTableViewController.h"
#import "AppDelegate.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface SetTableViewController ()
{
    AppDelegate *appDelegate;
}
@end

@implementation SetTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//-----------------------UITableViewDataSource-----------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 2;
    }
    
    else if(section == 1)
    {
        return 3;
    }
    
    else if(section == 2)
    {
        return 3;
    }
    
    else if(section == 3)
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
            cell = self.imageCachePathCell;
        }
        
        if(indexPath.row == 1)
        {
            cell = self.imageLoadCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.alertCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.cleanCacheCell;
        }
        if(indexPath.row == 2)
        {
            cell = self.upgradeCell;
        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.feedbackCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.scoreCell;
        }
        if(indexPath.row == 2)
        {
            cell = self.aboutCell;
        }
    }
    
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            cell = self.exitCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            [self exitActionSheet];
        }
    }
}

//----------------------------------UIActionSheetDelegate----------------------------------------//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //删除用户信息
        [self deleteUserInfo];
        [appDelegate switchRootViewController];
    }
}

- (void)exitActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"确定要退出?"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"确认"
                                                   otherButtonTitles:nil, nil];
    [actionSheet showInView:self.view];
}

-(void)deleteUserInfo
{
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]];
    
    BOOL isUserInfoFolderCreate = [appFileManager fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if(isUserInfoFolderCreate)
    {
        [appFileManager removeItemAtPath:UserInfoFolder error:nil];
    }
    
    //删除登录标记和当前的id
    if ([saveDefaults objectForKey:@"isLogin"])
    {
        [saveDefaults setObject:@"NO" forKey:@"isLogin"];
    }
    
    //退出RCIM
    [[RCIM sharedRCIM] disconnect:NO];
}

@end





















