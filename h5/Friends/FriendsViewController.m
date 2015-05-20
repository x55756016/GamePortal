//
//  FriendsViewController.m
//  h5
//
//  Created by wwj on 15/4/5.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "FriendsViewController.h"
#import "CommonTableViewCell.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "UserInfoTableViewController.h"
#import "h5kkContants.h"
#import "pinyin.h"
#import "ChineseString.h"
#import "CustomerChatViewController.h"
#import "RCHandShakeMessage.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "KKUtility.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface FriendsViewController ()
{
    NSArray *friendsArray;
    NSDictionary *userInfo;
}
@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataArr = [[NSMutableArray alloc] init];
    _sortedArrForArrays = [[NSMutableArray alloc]init];
    _sectionHeadsKeys = [[NSMutableArray alloc]init];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.friendTableView.tableFooterView = footLabel;
    
    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    
    //加载好友数据
    [self loadFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//--------------------------------------加载好友数据-----------------------------------------------//
-(void)loadFriends
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = @"friendList";
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        friendsArray = [NSArray arrayWithContentsOfFile:UserInfoFolder];
    }
   
    NSString *urlStr = GET_FRIEND;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setDidFailSelector:@selector(loadFriendsFail:)];
    [request setDidFinishSelector:@selector(loadFriendsFinish:)];
    [request startAsynchronous];
}

- (void)loadFriendsFinish:(ASIHTTPRequest *)request
{
    NSLog(@"loadFriendsFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"friendsdict[%@]",dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadFriendsData:dict];
    }
    
    [self sequence];
}

- (void)loadFriendsFail:(ASIHTTPRequest *)request
{
    [KKUtility showHttpErrorMsg:@"获取好友信息失败 " :request.error];
    [self sequence];
}

//好友数据刷表
-(void)loadFriendsData:(NSDictionary *)dict
{
    friendsArray = [dict objectForKey:@"ObjData"];
//    NSLog(@"friendsArray[%lu]%@", (unsigned long)friendsArray.count, friendsArray);
    
    //加载的人的数据保存至本地
    [self savePeopleDate:0];
}

//加载人的数据保存至本地
-(void)savePeopleDate:(int)peopleType
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = @"friendList";
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    if(peopleType == 0)
    {
        if (![friendsArray writeToFile:UserInfoFolder atomically:YES])
        {
            NSLog(@"保存好友信息失败");
        }
    }
}

//排序
-(void)sequence
{
    [_dataArr addObjectsFromArray:friendsArray];
    self.sortedArrForArrays = [ChineseString getChineseStringArr:_dataArr sectionHeadsKeys:self.sectionHeadsKeys];
    
    //添加置顶内容
    NSMutableArray *regularDataArr = [NSMutableArray arrayWithObjects:@"在线客服",@"新的朋友", @"群聊", nil];
    [regularDataArr addObjectsFromArray:self.sortedArrForArrays];
    self.sortedArrForArrays = regularDataArr;

    NSMutableArray *regularSectionHeadsKeysArr = [NSMutableArray arrayWithObjects:@"",@"", @"", nil];
    [regularSectionHeadsKeysArr addObjectsFromArray:self.sectionHeadsKeys];
    self.sectionHeadsKeys = regularSectionHeadsKeysArr;
    
    [self.friendTableView reloadData];
}

//----------------------------------------UITableViewDataSource-----------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedArrForArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 1|| section == 2)
    {
        return 1;
    }
    
    return  [[self.sortedArrForArrays objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0 || section == 1|| section == 2)
    {
        return nil;
    }
    
    return [self.sectionHeadsKeys objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionHeadsKeys;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"commonCells";
    [tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    CommonTableViewCell *commonTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section];
    if(indexPath.section > 2)
    {
        ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
        
        commonTableViewCell.nickNameLabel.text = [NSString stringWithFormat:@"%@",[str.userInfoDict objectForKey:@"NickName"]];
        NSString *HeadIMGstring = [str.userInfoDict objectForKey:@"PicPath"];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        [commonTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        return commonTableViewCell;
    }
    else
    {
        commonTableViewCell.nickNameLabel.text = (NSString *)arr;
        return commonTableViewCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section];
    if (indexPath.section == 0)//客服
    {
        [self chartTocustomerServices];
    }
    else if (indexPath.section == 1)//新的朋友
    {
        
    }
    else if (indexPath.section == 2)//群聊
    {
        
    }
    else
    {
        ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"PushUserInfo" sender:str.userInfoDict];
    }
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

-(void)chartTocustomerServices
{
    @try {
        NSString *customerServiceUserId = [self getKeFuId];
        CustomerChatViewController *temp = [[CustomerChatViewController alloc]init];
        
        temp.currentTarget = [self getKeFuId];
        temp.conversationType = ConversationType_CUSTOMERSERVICE;
        temp.currentTargetName = @"客服";
        //temp.enableSettings = NO;
        temp.enableVoIP = NO;
        RCHandShakeMessage *textMsg = [[RCHandShakeMessage alloc] init];
        [[RCIM sharedRCIM] sendMessage:ConversationType_CUSTOMERSERVICE targetId:customerServiceUserId content:textMsg delegate:nil];
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }

}

-(NSString*)getKeFuId
{
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//[documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* keFuId;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        keFuId = appCustomServiceKeyIM;
    else
        keFuId = @"kefu114";
    return keFuId;
}
@end






















