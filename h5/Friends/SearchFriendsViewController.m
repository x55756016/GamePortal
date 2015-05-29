//
//  SearchFriendsViewController.m
//  h5
//
//  Created by wwj on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "CommonTableViewCell.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "UserInfoTableViewController.h"
#import "h5kkContants.h"
#import "KKUtility.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface SearchFriendsViewController ()
{
    NSArray *searchArry;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
}
@end

@implementation SearchFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置焦点
    [self.searchTextField becomeFirstResponder];
    //获取用户信息
    userInfo=[KKUtility getUserInfoFromLocalFile];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableFooterView = footLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



//------------------------------------UITextFieldDelegate---------------------------------------------------------//
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchFriend:textField];
    [textField resignFirstResponder];
    return YES;
}

//进行搜索
-(void)searchFriend:(UITextField *)textField
{
    NSString *urlStr = FRIEND_SEARCH;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:textField.text forKey:@"friend"];
    [request setPostValue:@"1" forKey:@"pageindex"];
    [request setDidFailSelector:@selector(searchFriendFail:)];
    [request setDidFinishSelector:@selector(searchFriendFinish:)];
    [request startAsynchronous];
}

- (void)searchFriendFinish:(ASIHTTPRequest *)req
{
    NSLog(@"searchFriendFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"searchFrienddict[%@]",dict);
    
    [SVProgressHUD dismiss];
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        [self searchFriendData:dict];
    }
}

- (void)searchFriendFail:(ASIHTTPRequest *)req
{
    [SVProgressHUD dismiss];
   [KKUtility showHttpErrorMsg:@"查询好友失败 " :req.error];}

//好友数据刷表
-(void)searchFriendData:(NSDictionary *)dict
{
    searchArry = [dict objectForKey:@"ObjData"];
//    NSLog(@"searchArry[%lu]%@", (unsigned long)searchArry.count, searchArry);
    [self.searchTableView reloadData];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchArry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"commonCells";
    [tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    CommonTableViewCell *commonTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *searchDict = searchArry[indexPath.row];
    commonTableViewCell.nickNameLabel.text = [searchDict objectForKey:@"NickName"];
    
    NSString *HeadIMGstring = [searchDict objectForKey:@"PicPath"];
    HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
    [commonTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    return commonTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *searchDict = searchArry[indexPath.row];
    NSLog(@"查找到的人资料[%@]", searchDict);
    [self performSegueWithIdentifier:@"PushUserInfo" sender:searchDict];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end























