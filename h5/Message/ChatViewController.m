//
//  ChatViewController.m
//  h5
//
//  Created by wwj on 15/4/11.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "ChatViewController.h"
#import "RCPreviewViewController.h"
#import "ChatSettingViewController.h"
#import "UserInfoTableViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.enableSettings)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"设置"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(rightBarButtonItemPressed:)];
        [rightButton setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    //设置用户头像点击事件
    
    [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo)
    {
        NSLog(@"=======viewController[%@]=========", viewController);
        NSDictionary *userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.userId,@"UserId",userInfo.name,@"NickName",userInfo.portraitUri,@"PicPath",nil];
        [self performSegueWithIdentifier:@"PushUserInfo" sender:userInfoDict];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)rightBarButtonItemPressed:(id)sender
{
    ChatSettingViewController *csvc = [[ChatSettingViewController alloc]init];
    csvc.targetId = self.currentTarget;
    csvc.conversationType = self.conversationType;
    csvc.portraitStyle = RCUserAvatarCycle;
    [self.navigationController pushViewController:csvc animated:YES];
}

-(void)showPreviewPictureController:(RCMessage*)rcMessage
{
    RCPreviewViewController *rcpvc=[[RCPreviewViewController alloc]init];
    rcpvc.rcMessage = rcMessage;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rcpvc];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushUserInfo"])
    {
        UserInfoTableViewController *uitvc = (UserInfoTableViewController *)[segue destinationViewController];
        uitvc.FriendInfoDict = (NSDictionary *)sender;
    }
}

@end



























