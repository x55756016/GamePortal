//
//  ChatSettingViewController.m
//  h5
//
//  Created by wwj on 15/4/11.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "ChatSettingViewController.h"

@interface ChatSettingViewController ()
@end

@implementation ChatSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)renameDiscussionName:(RCConversationType)conversationType targetId:(NSString*)targetId oldName:(NSString*)oldName{
    
    RCRenameViewController *temp = [[RCRenameViewController alloc]init];
    temp.delegate = self;
    temp.targetId = targetId;
    temp.oldName = oldName;
    temp.conversationType =conversationType;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:temp];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)onAddButtonClicked:(RCConversationType)conversationType
{
    //单聊添加人员创建讨论组
    if (ConversationType_PRIVATE == conversationType)
    {
        RCSelectPersonViewController *temp = [[RCSelectPersonViewController alloc]init];
        temp.isMultiSelect = YES;
        temp.useMode = CreateMode;
        temp.portaitStyle = RCUserAvatarCycle;
        temp.preSelectedUserIds = @[self.targetId];
        temp.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:temp];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.translucent = NO;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    //多人聊天添加更多人
    if ( ConversationType_DISCUSSION == conversationType)
    {
        RCSelectPersonViewController *temp = [[RCSelectPersonViewController alloc]init];
        temp.isMultiSelect = YES;
        temp.useMode = InviteMode;
        temp.portaitStyle = RCUserAvatarCycle;
        NSMutableArray* preArray = [[NSMutableArray alloc]initWithArray:self.discussionInfo.memberIdList];
        for (NSInteger i =preArray.count-1; i>=0; i--)
        {
            NSString* userId = preArray[i];
            if ([userId isEqualToString:[self getCurrentUserId]])
            {
                [preArray removeObjectAtIndex:i];
            }
        }
        
        temp.preSelectedUserIds = preArray;
        temp.discussionInfo_invite = self.discussionInfo;
        temp.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:temp];
        nav.navigationBar.barStyle = UIBarStyleBlack;
        nav.navigationBar.translucent = NO;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)didSelectedPersons:(NSArray *)selectedArray viewController:(RCSelectPersonViewController *)viewController
{
    //创建多人聊天
    if (viewController.useMode == CreateMode)
    {
        NSInteger selectedCount = viewController.selectedPersonList.count;
        NSMutableString *discussionName = [NSMutableString string] ;
        NSMutableArray *memberIdArray =[NSMutableArray array];
        
        //之前已经选择的Id
        NSString* userId=(viewController.preSelectedUserIds)[0];
        [memberIdArray addObject:userId];
        RCUserInfo *userInfo=[self getUserInfoWithUserId:userId];
        
        if (userInfo)
        {
            [discussionName appendString:userInfo.name];
            [discussionName appendString:@","];
        }
        
        //后获取选中的人员
        for (int i=0; i<viewController.selectedPersonList.count; i++)
        {
            RCUserInfo *userinfo = (viewController.selectedPersonList)[i];
            if (i == selectedCount - 1)
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
        [[RCIMClient sharedRCIMClient] createDiscussion:discussionName userIdList:memberIdArray completion:^(RCDiscussion* discussionInfo) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //成功创建讨论组跳转
//                [weakSelf didCreateDiscussion:discussionInfo];
            });
        } error:^(RCErrorCode status) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == 0)
                {
                    NSLog(@"DISCUSSION_CREATE_SUCCEDD");
                    
                }
                else
                {
                    NSLog(@"DISCUSSION_INVITE_FAILED %d",(int)status);
                    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@""
                                                                  message:@"创建讨论组失败"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"确定"
                                                        otherButtonTitles: nil];
                    [alert show];
                }
            });
        }];
    }
    
    if (viewController.useMode == InviteMode)
    {
        NSMutableArray *memberIdArray =[NSMutableArray array];
        for (int i=0; i<viewController.selectedPersonList.count; i++)
        {
            RCUserInfo *userinfo = (viewController.selectedPersonList)[i];
            [memberIdArray addObject:userinfo.userId];
        }
        
        //添加新的成员
        [[RCIMClient sharedRCIMClient] addMemberToDiscussion:self.discussionInfo.discussionId userIdList:memberIdArray completion:^(RCDiscussion *discussion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil !=discussion) {
                    
                    //刷新讨论组设置
                    [self needUpdateDiscussionInfo:discussion];
                }
                else{
                    NSLog(@"%@",@"获取讨论组信息失败");
                }
            });
            
        } error:^(RCErrorCode status) {
            
        }];
    }
}
@end



































