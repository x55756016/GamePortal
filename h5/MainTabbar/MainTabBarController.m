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
    UIImage *MainSelectdImage = [[UIImage imageNamed:@"tab_main_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *MainItem = [self.tabBar.items objectAtIndex:0];
    MainItem.selectedImage = MainSelectdImage;
    
    UIImage *MessageSelectdImage = [[UIImage imageNamed:@"tab_message_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *MessageItem = [self.tabBar.items objectAtIndex:1];
    MessageItem.selectedImage = MessageSelectdImage;
    
    UIImage *FindSelectdImage = [[UIImage imageNamed:@"tab_find_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *FindItem = [self.tabBar.items objectAtIndex:2];
    FindItem.selectedImage = FindSelectdImage;
    
    UIImage *FriendsSelectdImage = [[UIImage imageNamed:@"tab_friends_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *FriendsItem = [self.tabBar.items objectAtIndex:3];
    FriendsItem.selectedImage = FriendsSelectdImage;
    
    UIImage *MySelectdImage = [[UIImage imageNamed:@"tab_my_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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


//－－ios6以后－－－－－－－－－－－－－－－－－－－－－
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
//－－结束 ios6以后－－－－－－－－－－－－－－－－－－－－－
@end




















