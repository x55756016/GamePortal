//
//  FindAroundTableViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "FindAroundTableViewController.h"
#import "AroundTableViewCell.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "UserInfoTableViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface FindAroundTableViewController ()
{
    NSArray *aroundArray;
    NSDictionary *userInfo;
}
@end

@implementation FindAroundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;
    
    //获取用户信息
    [self getUserInfo];
    
    //加载附近数据
    [self loadAround];
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
    }
}

//--------------------------------------加载附近数据-----------------------------------------------//
-(void)loadAround
{
    NSString *urlStr = GET_AROUND;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:@"1" forKey:@"pageindex"];
    [request setPostValue:@"0" forKey:@"lon"];
    [request setPostValue:@"0" forKey:@"lat"];
    [request setPostValue:@"0" forKey:@"dis"];
    [request setDidFailSelector:@selector(loadAroundFail:)];
    [request setDidFinishSelector:@selector(loadAroundFinish:)];
    [request startAsynchronous];
}

- (void)loadAroundFinish:(ASIHTTPRequest *)request
{
    NSLog(@"loadAroundFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"Arounddict[%@]", dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        aroundArray = [dict objectForKey:@"ObjData"];
//        NSLog(@"aroundArray[%d][%@]", aroundArray.count, aroundArray);
    }
    [self.tableView reloadData];
}

- (void)loadAroundFail:(ASIHTTPRequest *)request
{
    NSLog(@"loadAroundFail");
    [self.tableView reloadData];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aroundArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"aroundCells";
    [tableView registerNib:[UINib nibWithNibName:@"AroundTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    AroundTableViewCell *aroundTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *friendsDict = aroundArray[indexPath.row];
    aroundTableViewCell.nickNameLabel.text = [friendsDict objectForKey:@"NickName"];
    aroundTableViewCell.signLabel.text = [friendsDict objectForKey:@"Sign"];
    aroundTableViewCell.disLabel.text = [NSString stringWithFormat:@"%@m", [friendsDict objectForKey:@"dis"]];
    
    NSString *HeadIMGstring = [friendsDict objectForKey:@"PicPath"];
    HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_b.jpeg"];
    [aroundTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    return aroundTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *userInfoDict = aroundArray[indexPath.row];
    [self performSegueWithIdentifier:@"PushUserInfo" sender:userInfoDict];
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



























