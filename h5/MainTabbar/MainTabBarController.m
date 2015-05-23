//
//  MainTabBarController.m
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"

@interface MainTabBarController ()
{
    AppDelegate *appDelegate;
}
@end

@implementation MainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    appDelegate.mainTabBarController = self;
    
    //选中时字体的颜色
    //self.tabBar.tintColor = [UIColor colorWithRed:31./255. green:185./255. blue:34./255. alpha:1.0];
    
    //设置背景颜色
    //self.tabBar.barTintColor = [UIColor blackColor];
    @try{
    UIImage *MainSelectdImage = [[UIImage imageNamed:@"mainBoard_mainSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *MainItem = [self.tabBar.items objectAtIndex:0];
    MainItem.selectedImage = MainSelectdImage;
    
    UIImage *MessageSelectdImage = [[UIImage imageNamed:@"mainBoard_messageSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *MessageItem = [self.tabBar.items objectAtIndex:1];
    MessageItem.selectedImage = MessageSelectdImage;
    
    UIImage *FindSelectdImage = [[UIImage imageNamed:@"mainBoard_foundSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *FindItem = [self.tabBar.items objectAtIndex:2];
    FindItem.selectedImage = FindSelectdImage;
    
    UIImage *FriendsSelectdImage = [[UIImage imageNamed:@"mainBoard_friendsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *FriendsItem = [self.tabBar.items objectAtIndex:3];
    FriendsItem.selectedImage = FriendsSelectdImage;
    
    UIImage *MySelectdImage = [[UIImage imageNamed:@"mainBoard_meSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *MyItem = [self.tabBar.items objectAtIndex:4];
    MyItem.selectedImage = MySelectdImage;
    }
    @catch(NSException *exception) {
        
    }
    
    self.selectedIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//ios6以下兼容写法
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationMaskPortraitUpsideDown );
}

-(BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
    //传递入口1.选择首页时self.selectedViewController＝SquareNavigationController（home/index）
}
-(NSUInteger)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end




















