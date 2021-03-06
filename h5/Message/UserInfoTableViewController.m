
//
//  UserInfoTableViewController.m
//  h5
//
//  Created by wwj on 15/4/6.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "UserDataModel.h"
#import "ChatViewController.h"
#import "FriendsViewController.h"
#import "SnapChatViewController.h"
#import "FindAroundTableViewController.h"
#import "h5kkContants.h"
#import "AppDelegate.h"
#import "KKUtility.h"
#import "CurrentUser.h"
#import "UIImageView+WebCache.h"
#import "KKUtility.h"
#import "UIButton+ImageAndLabel.h"
#import "GameDetailViewController.h"
#import "ClickImage.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "FindTableViewController.h"
// [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

UIKIT_EXTERN NSString *userFolderPath;

@interface UserInfoTableViewController ()
{
    AppDelegate *appDelegate;
    NSDictionary *MyInfo;
    NSArray *userGameArray;
    NSArray *userAchievementArray;
    
    NSMutableArray *FrindGameImageArray;
    NSMutableArray *FrindHistoryImageArray;
    
    //好友列表
    NSArray  *friendsArray;
    NSString *Userid;
    int currentUserIndex;
    ASIFormDataRequest *request;
}
@end

@implementation UserInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FrindGameImageArray = [[NSMutableArray alloc] init];
    FrindHistoryImageArray = [[NSMutableArray alloc] init];
    
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.headImageView.frame = CGRectMake(self.headImageView.frame.origin.x, self.headImageView.frame.origin.y, 60, 60);
    self.headImageView.layer.cornerRadius = CGRectGetHeight([self.headImageView bounds])/2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    MyInfo=[KKUtility getUserInfoFromLocalFile];
    
//    [self getUserInfo];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            //获取所有好友
            [self loadFriends];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
//            [self.tableView reloadData];
            
        });
    });
   }

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//---------获取好友列表以判断是否是好友
-(void)loadFriends
{
  
    Userid= [MyInfo objectForKey:@"UserId"] ;
    
    friendsArray =[KKUtility GetFriendsFromLocal:Userid];
    
    if(friendsArray==nil || friendsArray.count<1){
        NSString *urlStr = GET_FRIEND;
        NSURL *url = [NSURL URLWithString:urlStr];
        
        request = [ASIFormDataRequest requestWithURL:url];
        [request setTimeOutSeconds:10.0];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request setPostValue:@"1.0" forKey:@"version"];
        [request setPostValue:[NSString stringWithFormat:@"%@",Userid] forKey:@"UserId"];
        [request setPostValue:[NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
        [request setDidFailSelector:@selector(loadFriendsFail:)];
        [request setDidFinishSelector:@selector(loadFriendsFinish:)];
        [request startAsynchronous];
    }else{
        //获取用户详情并显示
        [self GetUserDetail];
    }
}

- (void)loadFriendsFinish:(ASIHTTPRequest *)req
{
    NSLog(@"loadFriendsFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        friendsArray = [dict objectForKey:@"ObjData"];
        //加载的人的数据保存至本地
        [KKUtility saveFriendsToLocal:friendsArray :Userid];
        
        //获取用户详情并显示
        [self GetUserDetail];
    }
}

- (void)loadFriendsFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取好友信息失败 " :req.error];
}

//__________结束获取所有好友－－－－－－－－－－－－－－
//---------------------------------开始获取用户详细信息----------------------------------------------------------------------
-(void)GetUserDetail
{
    NSString *urlStr = USER_DETAIL;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    
    [request setPostValue:[NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]] forKey:@"FriendId"];
    
    [request setDidFailSelector:@selector(requestGetUserDetailFail:)];
    [request setDidFinishSelector:@selector(requestGetUserDetailFinish:)];
    [request startAsynchronous];
}

- (void)requestGetUserDetailFinish:(ASIHTTPRequest *)req
{
    @try {
        NSLog(@"requestGetUserDetailFinish");
        NSError *error;
        NSData *responseData = [req responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        //    NSLog(@"requestUserGame[%@]",dic);
        
        if([[dic objectForKey:@"IsSuccess"] integerValue])
        {
            NSArray *data= [dic objectForKey:@"ObjData"];
            self.FriendInfoDict =[data objectAtIndex:0];
            
            NSNumber *userid=[self.FriendInfoDict objectForKey:@"UserId"];
            NSString *useridstr=[NSString stringWithFormat:@"%@",userid];
            NSString *strSign=[self.FriendInfoDict objectForKey:@"Sign"];
            
            if([KKUtility StringIsEmptyOrNull:useridstr]==NO)
            {
                [self.FriendIdLabel setText:useridstr];
            }
        
            NSString *strDistinct=[self.FriendInfoDict objectForKey:@"Loc"];
            if([KKUtility StringIsEmptyOrNull:strDistinct]==NO)
            {
                NSArray *dicArray = [strDistinct componentsSeparatedByString:@","];
                NSString *discLongitude=[[dicArray objectAtIndex:0] substringFromIndex:1];
                NSString *discLatitude=[[dicArray objectAtIndex:1] substringToIndex:[[dicArray objectAtIndex:1] length]-1];
                CLLocation *endpoint=[[CLLocation alloc] initWithLatitude:[discLongitude doubleValue]   longitude:[discLatitude doubleValue] ];
                //Latitude 纬度， longitude 经度
                AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                NSString *DistinctMsg=[KKUtility calcutDistinct:kkAppDelegate.currentlogingUser.Location:endpoint];
                [self.FriedDistincLabel setText:DistinctMsg];
            }
            if([KKUtility StringIsEmptyOrNull:strSign]==NO)
            {
                [self.FriedSignLabel setText:strSign];
            }
            //显示用户的游戏
            [self GetUserGames];
        }
        
        //显示用户信息
        [self showUserInfo];
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
   
}

- (void)requestGetUserDetailFail:(ASIHTTPRequest *)req
{
  [KKUtility showHttpErrorMsg:@"获取用户详情失败 " :req.error];
}

//显示用户信息
-(void)showUserInfo
{
    NSString *HeadIMGstring = [self.FriendInfoDict objectForKey:@"PicPath"];
    NSNumber *FriendId=[self.FriendInfoDict objectForKey:@"UserId"];
    HeadIMGstring =[KKUtility getKKImagePath:HeadIMGstring:@"s"];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    
    self.nickNameLabel.text = [self.FriendInfoDict objectForKey:@"NickName"];
    self.accountTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",FriendId];
    self.signTableViewCell.detailTextLabel.text = [self.FriendInfoDict objectForKey:@"Sign"];
    
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *dintinc=[KKUtility getUserDistinctFromMyPoint:self.FriendInfoDict :kkAppDelegate.currentlogingUser];
    self.distanceTableViewCell.detailTextLabel.text = dintinc;
    
    for(int i=0;i<[friendsArray count];i++)
    {
        NSDictionary *dic=[friendsArray objectAtIndex:i];
        NSNumber *dicId=[dic objectForKey:@"UserId"];
        if([FriendId isEqualToNumber:dicId])
        {
            [[self AddFriendButton] setTitle:@"删除好友" forState:UIControlStateNormal];
            currentUserIndex=i;
        }
    }
}



//---------------------------------结束获取用户详细信息-----------------------------------------------------------------------

//发起聊天 发送消息
- (IBAction)singleChat:(id)sender
{
    @try {
        for(UIViewController *vc in self.navigationController.viewControllers)
        {
            if([vc isKindOfClass:[ChatViewController class]])
            {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
            //        if(([vc isKindOfClass:[SnapChatViewController class]])
            //           || ([vc isKindOfClass:[FriendsViewController class]])
            //
            //           || ([vc isKindOfClass:[FindTableViewController class]])
            //
            //           || ([vc isKindOfClass:[FindAroundTableViewController class]]))
            //        {
            //            [self performSegueWithIdentifier:@"PushChat" sender:nil];
            //            break;
            //        }
        }
        
        [self performSegueWithIdentifier:@"PushChat" sender:nil];
        
        
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }

}


//－－－－－－－添加删除好友
- (IBAction)AddFriend:(id)sender
{
     [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    UIButton *btn=(UIButton*)sender;
    if([btn.currentTitle isEqualToString:@"删除好友"]){
        NSString *urlStr = FriendRemove;
        NSURL *url = [NSURL URLWithString:urlStr];
        
        request = [ASIFormDataRequest requestWithURL:url];
        [request setTimeOutSeconds:10.0];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request setPostValue:@"1.0" forKey:@"version"];
        [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
        [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
        [request setPostValue:[NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]] forKey:@"removeUserId"];
        
        [request setDidFailSelector:@selector(requestFriendRemoveFail:)];
        [request setDidFinishSelector:@selector(requestUserFriendRemoveFinish:)];
        [request startAsynchronous];

        
    }else{
        NSString *urlStr = FIND_ADD;
        NSURL *url = [NSURL URLWithString:urlStr];
        
        request = [ASIFormDataRequest requestWithURL:url];
        [request setTimeOutSeconds:10.0];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        [request setPostValue:@"1.0" forKey:@"version"];
        [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
        [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
        
        [request setPostValue:[NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]] forKey:@"addUserId"];
        
        [request setPostValue:@"1" forKey:@"pageindex"];
        [request setDidFailSelector:@selector(requestFriendAddFail:)];
        [request setDidFinishSelector:@selector(requestUserFriendAddFinish:)];
        [request startAsynchronous];
    }
}

- (void)requestUserFriendAddFinish:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    [KKUtility justAlert:@"添加好友成功！"];

}

- (void)requestFriendAddFail:(ASIHTTPRequest *)req
{
    [SVProgressHUD dismiss];
   [KKUtility showHttpErrorMsg:@"添加好友失败 " :req.error];
}

- (void)requestUserFriendRemoveFinish:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    @try {
        
        [KKUtility justAlert:@"删除好友成功！"];
         NSMutableArray *friendAll= [friendsArray mutableCopy];
        [friendAll removeObjectAtIndex:currentUserIndex];
        [KKUtility saveFriendsToLocal:friendAll :nil];
    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
    
}

- (void)requestFriendRemoveFail:(ASIHTTPRequest *)req
{
   [SVProgressHUD dismiss];
   [KKUtility showHttpErrorMsg:@"删除好友失败 " :req.error];
}

//－－－－－－－－－－结束添加好友

//----------------------------------------------------------显示用户的游戏------------------------------------------------------------//
-(void)GetUserGames
{
    NSString *urlStr = GET_MY_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]] forKey:@"PlayerId"];
    [request setPostValue:@"1" forKey:@"pageindex"];
    [request setDidFailSelector:@selector(requestUserGameFail:)];
    [request setDidFinishSelector:@selector(requestUserGameFinish:)];
    [request startAsynchronous];
}

- (void)requestUserGameFinish:(ASIHTTPRequest *)req
{
    NSLog(@"requestUserGameFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self DealUserGameData:dic];
        //显示用户的荣誉墙
        [self RequestUserAchievement];
    }
}

- (void)requestUserGameFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取好友游戏列表失败 " :req.error];
}

-(void)DealUserGameData:(NSDictionary *)dic
{
    @try {
        userGameArray = [dic objectForKey:@"ObjData"];
        if(userGameArray==nil || [userGameArray count]<1)return;
        for (int i = 0; i < [userGameArray count]; i++) {
            NSDictionary *gameInfo=[userGameArray objectAtIndex:i];
            NSString *path = [gameInfo objectForKey:@"Logo"];
            [FrindGameImageArray addObject:path];
        }

    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
}

//----------------------------------------------------------显示用户的荣誉墙--------------------------------------------------------//
-(void)RequestUserAchievement
{
    NSString *urlStr = GET_GAME_ACHIEVEMENT;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]] forKey:@"AchiUserId"];
    [request setPostValue:@"1" forKey:@"PageIndex"];
    [request setDidFailSelector:@selector(requestUserAchievementFail:)];
    [request setDidFinishSelector:@selector(requestUserAchievementFinish:)];
    [request startAsynchronous];
}

- (void)requestUserAchievementFinish:(ASIHTTPRequest *)req
{
    NSLog(@"requestUserAchievementFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self DealUserAchievementData:dic];
    }
    [self.tableView reloadData];
    
}

- (void)requestUserAchievementFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取好友荣誉墙失败 " :req.error];
}

-(void)DealUserAchievementData:(NSDictionary *)dic
{
    @try {
        userAchievementArray = [dic objectForKey:@"ObjData"];
        if((NSNull*)userAchievementArray ==[NSNull null]
           || [userAchievementArray count]<1)return;
        NSLog(@"userAchievementArray[%lu]", (unsigned long)userAchievementArray.count);

        for (int i = 0; i < [userAchievementArray count]; i++) {
            NSDictionary *historyInfo=[userAchievementArray objectAtIndex:i];
            NSString *path = [historyInfo objectForKey:@"PicPath"];
            path=[KKUtility getKKImagePath:path :@"b"];
            [FrindHistoryImageArray addObject:path];

        }

    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
    
}

//------------------------------Table view data source----------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    
    else if(section == 1)
    {
        return 3;
    }
    
    else if(section == 2)
    {
        return 1;
    }
    if(section == 3)
    {
        return 1;
    }
    
    else if(section == 4)
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
            cell = self.HeadTableViewCell;
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
            cell = self.distanceTableViewCell;
        }
        if(indexPath.row == 2)
        {
            cell = self.signTableViewCell;
        }
    }
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            @try {
                if(FrindGameImageArray!=nil && [FrindGameImageArray count]>0)
                {
                    UIScrollView *imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 100)];
                    long width=[FrindGameImageArray count]*(80+10);
                    imageScrollView.contentSize =CGSizeMake(width,100);
                    for (int i = 0; i < [FrindGameImageArray count]; i++){
                        NSString *imageUrl=[FrindGameImageArray objectAtIndex:i];
                        
                        UIButton *imagebutton = [[UIButton alloc] initWithFrame:CGRectMake(i*80+10, 0, 70, 70)];
                        imagebutton.tag=i;
                        imagebutton.layer.masksToBounds = YES;
                        imagebutton.layer.cornerRadius = 5.0f;
//                        [imagebutton setImage:image forState:UIControlStateNormal];
                        NSURL *url = [NSURL URLWithString:imageUrl];
                        [imagebutton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"mainBoard_adLogoDefault"]];
        
                        
                        [imagebutton addTarget:self action:@selector(goGameDetail:) forControlEvents:UIControlEventTouchUpInside];
                        [imageScrollView addSubview:imagebutton];
                        
                        
                        NSString *title=[[userGameArray objectAtIndex:i] objectForKey:@"Title"];
                        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(i*80+10, 70, 70, 20)];
                        titleLabel.text=title;
                        titleLabel.textAlignment = NSTextAlignmentCenter;
                        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//                       titleLabel.adjustsFontSizeToFitWidth = YES;
                        [imageScrollView addSubview:titleLabel];

                    }
                    [_FriendGameListView addSubview:imageScrollView];
                }
            }
            @catch (NSException *exception) {
                [KKUtility showSystemErrorMsg:exception.reason:nil];
                
            }
              cell = self.GameListCell;
        }
    }
    
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            @try {
                if(FrindHistoryImageArray!=nil && [FrindHistoryImageArray count]>0){
                    [self getUserActiveHistoryAndShow];
                }
            }
            @catch (NSException *exception) {
                [KKUtility showSystemErrorMsg:exception.reason :nil];
            }
            cell = self.HistoryListCell;
        }
    }
    if(indexPath.section == 4)
    {
        if(indexPath.row == 0)
        {
            cell = self.contentTableViewCell;
        }
    }


    
    return cell;
}

- (IBAction)goGameDetail:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    NSDictionary *gameInfo=[userGameArray objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"showGameDetail" sender:gameInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushChat"])
    {
        SnapChatViewController *scvc = (SnapChatViewController *)[segue destinationViewController];
        scvc.portraitStyle = RCUserAvatarCycle;
        scvc.currentTarget = [NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]];
        scvc.currentTargetName = [self.FriendInfoDict objectForKey:@"NickName"];
        scvc.conversationType = ConversationType_PRIVATE;
        scvc.enableSettings = NO;
        scvc.enableVoIP = YES;
        scvc.enablePOI = NO;
    }
    if([segue.identifier isEqualToString:@"showGameDetail"])
    {
        GameDetailViewController *uitvc = (GameDetailViewController *)[segue destinationViewController];
        uitvc.gameDetailDict = (NSDictionary *)sender;
    }
}

-(void)scrollViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event whichView:(id)scrollView;
{
//    InfiniteScrollPicker *picker=(InfiniteScrollPicker *)scrollView;
//    UIImageView *selectView= picker.biggestView;
//    UIImage *image=selectView.image;
//    ClickImage *image=selectView;
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}

-(void)getUserActiveHistoryAndShow
{
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *imgArry=[[NSMutableArray alloc] init];
            for (int i = 0; i < [FrindHistoryImageArray count]; i++){
                @try {
                    NSString *imageUrl=[FrindHistoryImageArray objectAtIndex:i];
                    NSURL *url = [NSURL URLWithString:imageUrl];
                    UIImage *img=[[UIImage alloc] init];
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    img = [UIImage imageWithData: imageData];
                    if(img==nil)continue;
                    [imgArry addObject:img];
                    
                }
                @catch (NSException *exception) {
                    continue;
                }
            }
            if (imgArry != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  
//                   InfiniteScrollPicker *isp3 = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, 240, 320, 210)];
//                    [isp3 setImageAry:set3];
//                    [isp3 setHeightOffset:20];
//                    [isp3 setPositionRatio:2];
//                    [isp3 setAlphaOfobjs:0.8];
                    
                    InfiniteScrollPicker *isp = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 120)];
                    [isp setItemSize:CGSizeMake(90, 100)];
                    [isp setImageAry:imgArry];
                    [isp setHeightOffset:20];
                    [isp setPositionRatio:2];
                    [isp setAlphaOfobjs:0.6];
                    isp.touchesdelegate=self;
                    [_FriendHistoryListView addSubview:isp];
                });
            } else {
                
            } 
        });
    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
   
}
@end




















