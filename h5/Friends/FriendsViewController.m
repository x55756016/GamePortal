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
#import "FootTableViewCell.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface FriendsViewController ()
{
    NSArray *friendsArray;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
}
@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.friendTableView.tableFooterView = footLabel;
    
    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    
    [self UpAndDownPull];
    //加载好友数据
    //[self loadFriends];
    self.dataArr = [[NSMutableArray alloc] init];
    self.sortedArrForArrays = [[NSMutableArray alloc]init];
    self.sectionHeadsKeys = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//上下拉加载
-(void)UpAndDownPull
{
    //首次进来下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.friendTableView addLegendHeaderWithRefreshingBlock:^{
        //加载玩家动态
        [weakSelf loadFriends];
    }];
    [self.friendTableView.legendHeader beginRefreshing];
    
    //    [self.tableView addLegendFooterWithRefreshingBlock:^{
    //        [weakSelf loadMoreData];
    //    }];
}

//--------------------------------------加载好友数据-----------------------------------------------//
-(void)loadFriends
{
    @try {
        NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
        NSString *dataListName = @"friendList";
        NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
        
        BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
        if (isUserInfoFolderCreate)
        {
            friendsArray = [NSArray arrayWithContentsOfFile:UserInfoFolder];
            if(friendsArray.count==0)
            {
                return;
            }
        }
        
        NSString *urlStr = GET_FRIEND;
        NSURL *url = [NSURL URLWithString:urlStr];
        
        request = [ASIFormDataRequest requestWithURL:url];
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
    @catch (NSException *exception) {
        [self.friendTableView.header endRefreshing];
        [self.friendTableView.footer endRefreshing];
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
}

- (void)loadFriendsFinish:(ASIHTTPRequest *)req
{
    @try {
        
        NSLog(@"loadFriendsFinish");
        NSError *error;
        NSData *responseData = [req responseData];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        if([[dict objectForKey:@"IsSuccess"] integerValue])
        {
            [self.dataArr removeAllObjects];
            [self.sortedArrForArrays removeAllObjects];
            [self.sectionHeadsKeys removeAllObjects];
            
            [self loadFriendsData:dict];
        }
        [self sequence];
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
    @finally {
        [self.friendTableView.header endRefreshing];
        [self.friendTableView.footer endRefreshing];
    }
}

- (void)loadFriendsFail:(ASIHTTPRequest *)req
{
    [self.friendTableView.header endRefreshing];
    [self.friendTableView.footer endRefreshing];
    [KKUtility showHttpErrorMsg:nil :nil];
//    [self sequence];
}

//好友数据刷表
-(void)loadFriendsData:(NSDictionary *)dict
{
    @try {
        friendsArray = [dict objectForKey:@"ObjData"];
        //加载的人的数据保存至本地
        [self savePeopleDate:0];
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
    
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
    [self.dataArr addObjectsFromArray:friendsArray];
    self.sortedArrForArrays = [ChineseString getChineseStringArr:_dataArr sectionHeadsKeys:self.sectionHeadsKeys];
    
    //添加置顶内容
//    NSMutableArray *regularDataArr = [NSMutableArray arrayWithObjects:@"在线客服",@"新的朋友", @"群聊", nil];
     NSMutableArray *regularDataArr = [NSMutableArray arrayWithObjects:@"在线客服", nil];
    [regularDataArr addObjectsFromArray:self.sortedArrForArrays];
    self.sortedArrForArrays = regularDataArr;
    //添加置低内容
    NSString *FootMsg=[NSString stringWithFormat:@"%lu%@" , (unsigned long)[friendsArray count], @"位联系人" ];
    NSMutableArray *lastarry= [NSMutableArray arrayWithObjects:FootMsg, nil];;
    [self.sortedArrForArrays  addObjectsFromArray:lastarry];
    
    
    NSMutableArray *regularSectionHeadsKeysArr = [NSMutableArray arrayWithObjects:@"", nil];
    [regularSectionHeadsKeysArr addObjectsFromArray:self.sectionHeadsKeys];
    self.sectionHeadsKeys = regularSectionHeadsKeysArr;
    
    NSMutableArray *footHeadsKeysArr = [NSMutableArray arrayWithObjects:@"", nil];
    [self.sectionHeadsKeys addObjectsFromArray:footHeadsKeysArr];

    
    [self.friendTableView reloadData];
}

//----------------------------------------UITableViewDataSource-----------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sortedArrForArrays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        if(section == 0 || section==(self.sortedArrForArrays.count-1))
        {
            return 1;
        }
        return  [[self.sortedArrForArrays objectAtIndex:section] count];
    }
    @catch (NSException *exception) {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    @try {
        
        if(section == 0 )
        {
            return nil;
        }
        return [self.sectionHeadsKeys objectAtIndex:section];
    }
    @catch (NSException *exception) {
           return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    @try {
        
        return self.sectionHeadsKeys;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        NSLog(@"self.sortedArrForArrays=%ld,indexPath.section=%ld",(long)self.sortedArrForArrays.count,(long)indexPath.section);

        
        NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section];
        if(indexPath.section > 0)
        {
            if(indexPath.section==(self.sortedArrForArrays.count-1))
            {
                [tableView registerNib:[UINib nibWithNibName:@"FootTableViewCell" bundle:nil] forCellReuseIdentifier:@"FootTableViewCell"];
                FootTableViewCell *footTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"FootTableViewCell" forIndexPath:indexPath];
                [footTableViewCell.FootLabel setText:(NSString *)arr];
                return footTableViewCell;
                
            }
            else
            {
                static NSString *reuseIdentifier = @"commonCells";
                [tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
                CommonTableViewCell *commonTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

                ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
                commonTableViewCell.nickNameLabel.text = [NSString stringWithFormat:@"%@",[str.userInfoDict objectForKey:@"NickName"]];
                NSString *HeadIMGstring = [str.userInfoDict objectForKey:@"PicPath"];
                HeadIMGstring = [KKUtility getKKImagePath:HeadIMGstring:@"s"];
                [commonTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
                
                return commonTableViewCell;
            }
        }
        else
        {
            static NSString *reuseIdentifier = @"commonCells";
            [tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
            CommonTableViewCell *commonTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

            [commonTableViewCell.headImageView setImage:[UIImage imageNamed:@"kefu"]];
            commonTableViewCell.nickNameLabel.text = (NSString *)arr;
            return commonTableViewCell;
        }
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
    
//    [self.labFriendcount setText:countFriend];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSArray *arr = [self.sortedArrForArrays objectAtIndex:indexPath.section];
        if (indexPath.section == 0)//客服
        {
            [self chartTocustomerServices];
        }
        else
        {
            ChineseString *str = (ChineseString *) [arr objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"PushUserInfo" sender:str.userInfoDict];
        }
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
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
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//
//    [documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* keFuId;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        keFuId = appCustomServiceKeyIM;
    else
        keFuId = @"kefu114";
    return keFuId;
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end






















