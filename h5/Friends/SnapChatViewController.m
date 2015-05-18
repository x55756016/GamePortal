//
//  SnapChatViewController.m
//  h5
//
//  Created by wwj on 15/4/14.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SnapChatViewController.h"
#import "RCPreviewViewController.h"
#import "ChatViewController.h"

@interface SnapChatViewController ()

@end

@implementation SnapChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置用户头像点击事件
    [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo)
    {
         NSLog(@"------------viewController[%@]----------", viewController);
        
        if([viewController isKindOfClass:[SnapChatViewController class]])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

@end















