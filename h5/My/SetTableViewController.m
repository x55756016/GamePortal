//
//  SetTableViewController.m
//  h5
//
//  Created by hf on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SetTableViewController.h"
#import "AppDelegate.h"
#import "HomeInfoViewController.h"
#import "KKUtility.h"

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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 3;
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
//        if(indexPath.row == 0)
//        {
//            cell = self.imageCachePathCell;
//        }
//        
//        if(indexPath.row == 1)
//        {
//            cell = self.imageLoadCell;
//        }
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
    
    if(indexPath.section == 1)
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
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.exitCell;
        }

    }
    
//    if(indexPath.section == 3)
//    {
//           }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSInteger indexSection = indexPath.section;
    NSInteger indexRow=indexPath.row;
    NSString *webUrl=@"";
    if(indexSection==0)
    {
        [KKUtility justAlert:@"暂未开放"];
        return;
    }
    if(indexSection==1)
    {
        if(indexRow==0)
        {  //意见反馈
            webUrl=KKWeb_Feedback;
        }
        if(indexRow==1)
        {
            //去评分
            NSString *str = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", KKAppleID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            return;
        }
        if(indexRow==2)
        {
            //关于
            webUrl=KKWeb_About;
        }
    }
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            [self exitActionSheet];
        }
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





















