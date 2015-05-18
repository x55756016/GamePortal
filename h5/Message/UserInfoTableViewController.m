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
#import "ASIFormDataRequest.h"
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


UIKIT_EXTERN NSString *userFolderPath;

@interface UserInfoTableViewController ()
{
    AppDelegate *appDelegate;
    NSDictionary *MyInfo;
    NSArray *userGameArray;
    NSArray *userAchievementArray;
    
    NSMutableArray *FrindGameImageArray;
    NSMutableArray *FrindHistoryImageArray;

}
@end

@implementation UserInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.headImageView.frame = CGRectMake(self.headImageView.frame.origin.x, self.headImageView.frame.origin.y, 60, 60);
    self.headImageView.layer.cornerRadius = CGRectGetHeight([self.headImageView bounds])/2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    MyInfo=[KKUtility getUserInfoFromLocalFile];
    
//    [self getUserInfo];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
            //获取用户详情并显示
            [self GetUserDetail];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新界面
            [self.tableView reloadData];
            
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
//---------------------------------开始获取用户详细信息----------------------------------------------------------------------
-(void)GetUserDetail
{
    NSString *urlStr = USER_DETAIL;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
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

- (void)requestGetUserDetailFinish:(ASIHTTPRequest *)request
{
    NSLog(@"requestGetUserDetailFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    //    NSLog(@"requestUserGame[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        NSArray *data= [dic objectForKey:@"ObjData"];
        self.FriendInfoDict =[data objectAtIndex:0];
        NSLog(@"UserDetail%@", self.FriendInfoDict);
        
        //显示用户的游戏
        [self showUserGames];
    }
    
    //显示用户信息
    [self showUserInfo];
}

- (void)requestGetUserDetailFail:(ASIHTTPRequest *)request
{
    NSLog(@"requestGetUserDetailFail");
}

//显示用户信息
-(void)showUserInfo
{
    NSString *HeadIMGstring = [self.FriendInfoDict objectForKey:@"PicPath"];
    NSString *existStr = @"_b.jpg";
    
    if ([HeadIMGstring rangeOfString:existStr].location == NSNotFound)
    {
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
    }
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    
    self.nickNameLabel.text = [self.FriendInfoDict objectForKey:@"NickName"];
    self.accountTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[self.FriendInfoDict objectForKey:@"UserId"]];
    self.signTableViewCell.detailTextLabel.text = [self.FriendInfoDict objectForKey:@"Sign"];
    
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *dintinc=[KKUtility getUserDistinctFromMyPoint:self.FriendInfoDict :kkAppDelegate.currentlogingUser];
    self.distanceTableViewCell.detailTextLabel.text = dintinc;
}



//---------------------------------结束获取用户详细信息-----------------------------------------------------------------------

//发起聊天
- (IBAction)singleChat:(id)sender
{
    NSLog(@"all[%@]", self.navigationController.viewControllers);
    for(UIViewController *vc in self.navigationController.viewControllers)
    {
        if([vc isKindOfClass:[ChatViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
        
        if(([vc isKindOfClass:[SnapChatViewController class]]) || ([vc isKindOfClass:[FriendsViewController class]]) || ([vc isKindOfClass:[FindAroundTableViewController class]]))
        {
            [self performSegueWithIdentifier:@"PushChat" sender:nil];
            break;
        }
    }
}


//－－－－－－－添加好友
- (IBAction)AddFriend:(id)sender
{
    
    NSString *urlStr = FIND_ADD;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
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

- (void)requestUserFriendAddFinish:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加好友成功！"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    [alert show];
    NSLog(@"requestUserFriendAddFinish");
}

- (void)requestFriendAddFail:(ASIHTTPRequest *)request
{
    NSLog(@"requestFriendAddFail");
}

//－－－－－－－－－－结束添加好友

//----------------------------------------------------------显示用户的游戏------------------------------------------------------------//
-(void)showUserGames
{
    NSString *urlStr = GET_MY_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
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

- (void)requestUserGameFinish:(ASIHTTPRequest *)request
{
    NSLog(@"requestUserGameFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
//        NSArray *data= [dic objectForKey:@"ObjData"];
        [self DealUserGameData:dic];
        //显示用户的荣誉墙
        [self RequestUserAchievement];
    }
}

- (void)requestUserGameFail:(ASIHTTPRequest *)request
{
    NSLog(@"requestUserGameFail");
    //显示用户的荣誉墙
    [self RequestUserAchievement];
}

-(void)DealUserGameData:(NSDictionary *)dic
{
    userGameArray = [dic objectForKey:@"ObjData"];
    if([userGameArray count]<1)return;
    NSLog(@"userGameArray[%lu]%@", (unsigned long)userGameArray.count, userGameArray);
    
    FrindGameImageArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [userGameArray count]; i++) {
        NSDictionary *gameInfo=[userGameArray objectAtIndex:i];
        NSString *path = [gameInfo objectForKey:@"Logo"];
        
       UIImage *image=[KKUtility getImageFromLocal:path];
        if(image==nil)
        {
        NSURL *url = [NSURL URLWithString:path];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData: imageData];
            [KKUtility saveImageToLocal:image :path];
        }
        //      CGSize size  = CGSizeMake(179, 208);
        //      [ImageArray addObject:[self resizeImage:image scaledToSize:size]];
        [FrindGameImageArray addObject:image];
    }
}

//----------------------------------------------------------显示用户的荣誉墙--------------------------------------------------------//
-(void)RequestUserAchievement
{
    NSString *urlStr = GET_GAME_ACHIEVEMENT;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
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

- (void)requestUserAchievementFinish:(ASIHTTPRequest *)request
{
    NSLog(@"requestUserAchievementFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"requestUserAchievement[%@]",dic);
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self DealUserAchievementData:dic];
    }
    [self.tableView reloadData];
    
}

- (void)requestUserAchievementFail:(ASIHTTPRequest *)request
{
    
    [self.tableView reloadData];
    NSLog(@"requestUserAchievementFail");
}

-(void)DealUserAchievementData:(NSDictionary *)dic
{
    userAchievementArray = [dic objectForKey:@"ObjData"];
    if([userAchievementArray count]<1)return;
    NSLog(@"userAchievementArray[%lu]%@", (unsigned long)userAchievementArray.count, userAchievementArray);
    
    FrindHistoryImageArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [userAchievementArray count]; i++) {
        NSDictionary *historyInfo=[userAchievementArray objectAtIndex:i];
        NSString *path = [historyInfo objectForKey:@"PicPath"];
        path=[KKUtility getImagePath:path :@"s"];
        UIImage *image=[KKUtility getImageFromLocal:path];
        if(image==nil)
        {
            NSURL *url = [NSURL URLWithString:path];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData: imageData];
            if(image==nil)
            {
               continue;
            }else{
                
                [KKUtility saveImageToLocal:image :path];
                
                [FrindHistoryImageArray addObject:image];
            }
        }else{
             [FrindHistoryImageArray addObject:image];
        }

    }

}

//------------------------------Table view data source----------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
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
                if([FrindGameImageArray count]>0)
                {
                UIScrollView *imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 79)];  ;
                imageScrollView.pagingEnabled = YES;
                imageScrollView.showsHorizontalScrollIndicator = NO;
                //            [isp setItemSize:CGSizeMake(79, 79)];
                //           	 [UIScrollView :FrindGameImageArray];
                for (int i = 0; i < [FrindGameImageArray count]; i++) {
                    UIImage *image=[FrindGameImageArray objectAtIndex:i];
                    
                    
                    UIButton *imagebutton = [[UIButton alloc] initWithFrame:CGRectMake(i*80, 0, 79, 79)] ;
                    //UIButton *radarButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
//                    imageView.userInteractionEnabled=YES;//与用户交互
//                    //为UIImageView添加点击手势
//                    UITapGestureRecognizer *tap;
//                    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//                    tap.numberOfTapsRequired = 1;//tap次数
//                    tap.numberOfTouchesRequired = 1;//手指数
//                    [imageView addGestureRecognizer:tap];
                    imagebutton.tag=i;
                    imagebutton.layer.masksToBounds = YES;
                    imagebutton.layer.cornerRadius = 5.0f;
//                    [imagebutton setImage:image forState:UIControlStateNormal];
                    NSString *title=[[userGameArray objectAtIndex:i] objectForKey:@"Title"];
//                    [imagebutton setTitle:title forState:UIControlStateNormal];
                    [imagebutton setImage:image withTitle:title forState:UIControlStateNormal];
                    [imagebutton addTarget:self action:@selector(goGameDetail:) forControlEvents:UIControlEventTouchUpInside];
                    [imageScrollView addSubview:imagebutton];
                    
                    [_FriendGameListView addSubview:imageScrollView];
                }
                }
            }
            @catch (NSException *exception) {
                
            }
              cell = self.GameListCell;
        }
    }
    
    if(indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            InfiniteScrollPicker *isp = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, 0, 320, 79)];
            [isp setItemSize:CGSizeMake(79, 79)];
            [isp setImageAry:FrindHistoryImageArray];
            
            [isp setHeightOffset:20];
            [isp setPositionRatio:2];
            [isp setAlphaOfobjs:0.8];
            
            [_FriendHistoryListView addSubview:isp];
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

@end




















