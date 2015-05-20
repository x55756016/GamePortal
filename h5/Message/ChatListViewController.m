//
//  ChatListViewController.m
//  h5
//
//  Created by hf on 15/4/10.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "ChatListViewController.h"
#import "ASIFormDataRequest.h"
#import "ChatViewController.h"
#import "h5kkContants.h"
#import "AppDelegate.h"
#import "RCHandShakeMessage.h"
#import "CustomerChatViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface ChatListViewController ()
{
    NSArray *friendsArray;
    NSDictionary *locationUserInfo;
    AppDelegate *appDelegate;
}
@end

@implementation ChatListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.portraitStyle = RCUserAvatarCycle;
//    self.navigationItem.leftBarButtonItem = nil;
    [self setNavigationTitle:@"消息" textColor:[UIColor whiteColor]];
    [self configureNavigationBar];
    
    //自定义导航左右按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"选择"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(rightBarButtonItemPressed:)];
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem=nil;
    
    //获取用户信息
    locationUserInfo = [KKUtility getUserInfoFromLocalFile];
    
    //加载好友数据
    [self loadFriends];
    
    // 设置好友信息提供者。
    [RCIM setFriendsFetcherWithDelegate:self];

    // 设置用户信息提供者。
    [RCIM setUserInfoFetcherWithDelegate:self isCacheUserInfo:YES];
    
    //设置连接状态变化的监听器。
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    //设置接收消息的监听器。
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    
    //添加kk助手
    [self addKKAssistant];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear未读[%d]", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]);
    if([[RCIM sharedRCIM] getTotalUnreadCount] > 0)
    {
        [[appDelegate.mainTabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]];
    }
    else
    {
        [[appDelegate.mainTabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.conversationListView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-49-64);
    
//    [self.conversationStore 
     self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//添加kk助手
-(void)addKKAssistant
{
    
}

- (void)configureNavigationBar
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

//重载右边导航按钮的事件
-(void)rightBarButtonItemPressed:(id)sender
{
    //跳转好友列表界面，可是是融云提供的UI组件，也可以是自己实现的UI
    RCSelectPersonViewController *rcspvc = [[RCSelectPersonViewController alloc]init];
    rcspvc.isMultiSelect = YES;
    rcspvc.portaitStyle = RCUserAvatarCycle;
    rcspvc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rcspvc];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
}



-(void)didSelectedPersons:(NSArray*)selectedArray viewController:(RCSelectPersonViewController *)viewController
{
    if(selectedArray == nil || selectedArray.count == 0)
    {
        NSLog(@"Select person array is nil");
        return;
    }
    int count = (int)selectedArray.count;
    
    //只选择一个人得时候,创建单人聊天
    if (1 == count)
    {
        RCUserInfo *rcUserInfo = selectedArray[0];
        [self startPrivateChat:rcUserInfo];
    }
    //选择多个人得时候
    else if(count  > 1)
    {
        [self startDiscussionChat:selectedArray];
    }
}

//启动一对一聊天
-(void)startPrivateChat:(RCUserInfo *)userInfo
{
    [self performSegueWithIdentifier:@"PushChat" sender:userInfo];
}

//启动讨论组
-(void)startDiscussionChat:(NSArray*)userInfos
{
    NSMutableString *discussionName = [NSMutableString string];
    NSMutableArray *memberIdArray =[NSMutableArray array];
    NSInteger count = userInfos.count;
    
    for (int i = 0; i < count; i++)
    {
        RCUserInfo *userinfo = userInfos[i];
        if (i == userInfos.count - 1)
        {
            [discussionName appendString:userinfo.name];
        }
        else
        {
            [discussionName  appendString:[NSString stringWithFormat:@"%@%@",userinfo.name,@","]];
        }
        [memberIdArray addObject:userinfo.userId];
    }
    
    //创建讨论组
    [[RCIMClient sharedRCIMClient]createDiscussion:discussionName userIdList:memberIdArray completion:^(RCDiscussion *discussInfo) {
            NSLog(@"create discussion ssucceed!");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self performSegueWithIdentifier:@"PushChat" sender:discussInfo];
            });
    } error:^(RCErrorCode status) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
            
                NSLog(@"DISCUSSION_INVITE_FAILED %d",(int)status);
                UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@""
                                                              message:@"创建讨论组失败"
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles: nil];
                [alert show];
            });
    }];
}

//重载选择表格事件
-(void)onSelectedTableRow:(RCConversation*)conversation
{
    [self performSegueWithIdentifier:@"PushChat" sender:conversation];
}

//-----------------------------------------------RCIMReceiveMessageDelegate--------------------------------------//
//接收消息的监听器
-(void)didReceivedMessage:(RCMessage *)message left:(int)nLeft
{
    if (0 == nLeft)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"ChatListViewController未读[%d]", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]);
            if([[RCIM sharedRCIM] getTotalUnreadCount] > 0)
            {
                [UIApplication sharedApplication].applicationIconBadgeNumber = [[RCIM sharedRCIM] getTotalUnreadCount];
                [[appDelegate.mainTabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]];
            }
        });
    }
    
    [[RCIM sharedRCIM] invokeVoIPCall:self message:message];
}

//-----------------------------------------------RCIMConnectionStatusDelegate------------------------------------//
-(void)responseConnectionStatus:(RCConnectionStatus)status
{
    if (ConnectionStatus_NETWORK_UNAVAILABLE == status)
    {
        [RCIMClient reconnect:nil];
    }
}

//-----------------------------------RCIMFriendsFetcherDelegate-------------------------------------------------//
//获取好友信息列表
-(NSArray *)getFriends
{
    self.allFriendsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    //添加置顶内容
//    NSMutableArray *regularDataArr = [NSMutableArray arrayWithObjects:@"新的朋友", @"群聊", nil];
//    [regularDataArr addObjectsFromArray:self.sortedArrForArrays];
//    self.sortedArrForArrays = regularDataArr;
    RCUserInfo *rcUserInfo = [RCUserInfo new];
    rcUserInfo.userId =  [NSString stringWithFormat:@"%@", @"UserId"];
    rcUserInfo.name = @"KK玩客服";
    
    NSString *HeadIMGstring = @"PicPath";
    HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
    rcUserInfo.portraitUri = HeadIMGstring;
    [self.allFriendsArray addObject:rcUserInfo];
    
    
    for(int i= 0; i < friendsArray.count; i++)
    {
        NSDictionary *dic = friendsArray[i];
        RCUserInfo *rcUserInfo = [RCUserInfo new];
        rcUserInfo.userId =  [NSString stringWithFormat:@"%@", [dic objectForKey:@"UserId"]];
        rcUserInfo.name = [dic objectForKey:@"NickName"];
        
        NSString *HeadIMGstring = [dic objectForKey:@"PicPath"];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        rcUserInfo.portraitUri = HeadIMGstring;
        [self.allFriendsArray addObject:rcUserInfo];
    }

    return self.allFriendsArray;
}

//-----------------------------------RCIMUserInfoFetcherDelegagte-----------------------------------------------//
-(void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion
{
//    NSLog(@"getUserInfoWithUserId[%@]userInfo[%@]", userId, completion);
    
    if([userId length] == 0)
    {
        return completion(nil);
    }
    
    if([userId isEqualToString:[NSString stringWithFormat:@"%@", [locationUserInfo objectForKey:@"UserId"]]])
    {
        RCUserInfo *user = nil;
        user = [[RCUserInfo alloc]init];
        user.userId = userId;
        user.name = [locationUserInfo objectForKey:@"NickName"];
        
        NSString *HeadIMGstring = [locationUserInfo objectForKey:@"PicPath"];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        user.portraitUri = HeadIMGstring;
        return completion(user);
    }
    else
    {
        RCUserInfo *user = nil;
        for(NSDictionary *friendsDict in friendsArray)
        {
            NSString *friendUserId = [NSString stringWithFormat:@"%@", [friendsDict objectForKey:@"UserId"]];
            if([userId isEqualToString:friendUserId])
            {
                user = [[RCUserInfo alloc]init];
                user.userId = friendUserId;
                user.name = [friendsDict objectForKey:@"NickName"];
                
                NSString *HeadIMGstring = [friendsDict objectForKey:@"PicPath"];
                HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
                user.portraitUri = HeadIMGstring;
                return completion(user);
            }
        }
    }
}



//--------------------------------------加载好友数据------------------------------------------------------------//
-(void)loadFriends
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"FriendsView"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        friendsArray = [NSArray arrayWithContentsOfFile:UserInfoFolder];
    }
    else
    {
        NSString *urlStr = GET_FRIEND;
        NSURL *url = [NSURL URLWithString:urlStr];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setTimeOutSeconds:5.0];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request setPostValue:@"1.0" forKey:@"version"];
        [request setPostValue:[NSString stringWithFormat:@"%@", [locationUserInfo objectForKey:@"UserId"]] forKey:@"UserId"];
        [request setPostValue:[NSString stringWithFormat:@"%@", [locationUserInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
        [request setDidFailSelector:@selector(loadFriendsFail:)];
        [request setDidFinishSelector:@selector(loadFriendsFinish:)];
        [request startAsynchronous];
    }
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
}

- (void)loadFriendsFail:(ASIHTTPRequest *)request
{
    [KKUtility showHttpErrorMsg:@"获取好友信息失败 " :request.error];
}

//好友数据刷表
-(void)loadFriendsData:(NSDictionary *)dict
{
    friendsArray = [dict objectForKey:@"ObjData"];
//    NSLog(@"friendsArray[%lu]%@", (unsigned long)friendsArray.count, friendsArray);
    
    //加载的人的数据保存至本地
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"FriendsView"];
    if (![friendsArray writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存好友信息失败");
    }
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushChat"])
    {
        if([sender isKindOfClass:[RCUserInfo class]])
        {
            if(sender!=nil){
            RCUserInfo *rcUserInfo = (RCUserInfo *)sender;
            ChatViewController *cvc = (ChatViewController *)[segue destinationViewController];
            cvc.portraitStyle = RCUserAvatarCycle;
            cvc.currentTarget = rcUserInfo.userId;
            cvc.currentTargetName = rcUserInfo.name;
            cvc.conversationType = ConversationType_PRIVATE;
            cvc.enablePOI = NO;
            [self addChatController:cvc];
            }
        }
        
        if([sender isKindOfClass:[RCConversation class]])
        {
            RCConversation *conversation = (RCConversation *)sender;
            ChatViewController *cvc = (ChatViewController *)[segue destinationViewController];
            cvc.portraitStyle = RCUserAvatarCycle;
            cvc.currentTarget = conversation.targetId;
            cvc.conversationType = conversation.conversationType;
            cvc.currentTargetName = conversation.conversationTitle;
            cvc.enablePOI = NO;
            [self addChatController:cvc];
        }
        
        if([sender isKindOfClass:[RCDiscussion class]])
        {
            RCDiscussion *rcDiscussion = (RCDiscussion *)sender;
            ChatViewController *cvc = (ChatViewController *)[segue destinationViewController];
            cvc.portraitStyle = RCUserAvatarCycle;
            cvc.currentTarget = rcDiscussion.discussionId;
            cvc.currentTargetName = rcDiscussion.discussionName;
            cvc.conversationType = ConversationType_DISCUSSION;
            cvc.enablePOI = NO;
            [self addChatController:cvc];
        }
    }
}

- (IBAction)ShowCustomServicer:(id)sender {
   
}
@end











