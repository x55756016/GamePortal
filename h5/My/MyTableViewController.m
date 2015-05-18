//
//  MyTableViewController.m
//  h5
//
//  Created by hf on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "MyTableViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface MyTableViewController ()
{
    AppDelegate *appDelegate;
    NSDictionary *userInfo;
}
@end

@implementation MyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.headImageView.frame = CGRectMake(self.headImageView.frame.origin.x, self.headImageView.frame.origin.y, 60, 60);
    self.headImageView.layer.cornerRadius = CGRectGetHeight([self.headImageView bounds])/2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUserInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//本地获取用户信息
-(void)getUserInfo
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        userInfo = [NSDictionary dictionaryWithContentsOfFile:UserInfoFolder];
//        NSLog(@"userInfo[%@]", userInfo);
        
        //昵称
        self.nickNameLabel.text = [userInfo objectForKey:@"NickName"];
        
        //头像
        [self getUserIcon];
    }
}

-(void)getUserIcon
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"icon.jpg"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        self.headImageView.image = [UIImage imageWithContentsOfFile:UserInfoFolder];
    }
    else
    {
        NSString *HeadIMGstring = [userInfo objectForKey:@"PicPath"];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    }
}

-(void)saveUserIcon
{
    //保存至本地
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *imageFolder = [userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]];
    NSString *imageName = [imageFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"icon.jpg"]];
    NSData *imageData = UIImageJPEGRepresentation(self.headImageView.image, 1);
    [imageData writeToFile:imageName atomically:YES];
}

//------------------------------------------ Table view data source --------------------------------------------//
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
            cell = self.selectHeadImageTableViewCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.accountTableViewCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.vipTableViewCell;
        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.settingTableViewCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end




















