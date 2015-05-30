//
//  h5kkContants.h
//  h5
//
//  Created by hf on 15/4/17.
//  Copyright (c) 2015年 hf. All rights reserved.
//
#define KKAppleID @"com.shenyang.h5"//AppID

#define	KKDebug	 @"1"//1 开发调试阶段，0 发布上线


#define	HOST_HEADER	 @"http://www.h5kk.com"

#define GET_FRIEND              [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/Friend"]
#define USER_INFO_EDIT          [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/UserInfoEdit"]
#define FIND_PWD                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKAccount/FindPassword"]
#define GET_GAME_RANK           [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/GameAllRank"]
#define GET_GAME_LIST           [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/cms/AjaxGetList"]
#define GET_MY_GAME             [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/MyGame"]
#define GET_GAME_TYPE           [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/cms/AjaxGetType"]
#define ADD_GAME                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/AddGame"]
#define LOGIN                   [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKAccount/LogOn"]
#define REGISTER                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKAccount/RegisterUser"]
#define FRIEND_SEARCH           [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/FriendSearch"]
#define GAME_SEARCH             [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/cms/AjaxSearch"]
#define GET_FLASH_LIST          [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/cms/AjaxGetFlashList"]
#define GET_NEW_USER            [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/GetNewUserKK"]
#define GET_GAME_ACHIEVEMENT    [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/Achievement"]
#define GET_ACTIVE_LIST         [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/GetActiveList"]
#define GET_KK_AROUND           [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/KKAround"]
#define GET_AROUND              [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/UserAround"]

//微信AppId
#define KKWebChartAppid @"wx6f12d1a412f2bf36"
//科大讯飞sdk
#define KKAPPID_VALUE @"5552ef54"
#define TIMEOUT_VALUE         @"20000"            // timeout      连接超时的时间，以ms为单位


//融云客服
#define appCustomServiceKeyIM @"KEFU1430041496222"

//添加好友 egg：UserId=321938&UserKey=E10ADC3949&AreaId=1&GameId=0&lon=113.936372&lat=22.546721
#define FIND_ADD                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/FriendAdd"]
//删除好友 egg：UserId=321976&UserKey=E10ADC3949&removeUserId=321938
#define FriendRemove            [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/FriendRemove"]
//获取单个玩家详细信息 egg：UserId=321938&UserKey=E10ADC3949&FriendId=321970
#define USER_DETAIL             [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/FriendDetail"]
//添加玩游戏动态 egg：UserId=321938&UserKey=E10ADC3949&AreaId=1&GameId=0&lon=113.936372&lat=22.546721
#define USER_AddKKAround        [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/AddKKAround"]
//获取游戏详情
#define Get_GameDetailInfo      [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/cms/AjaxGetContent"]
//上传战绩墙
#define ADD_GameAchievement     [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/AchievementAdd"]

//获取产品价格
#define GET_ProductItem     [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKData/ProductItem"]
//上传购买成功凭据
#define SavePurchased_Credentials     [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKPay/ApplePay"]

//修改密码
#define KKUser_ChangePassword                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKUser/ChangePassword"]


//会员－会员说明
#define KKWeb_VipInfo                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKMsg/VipInfo"]
//会员－会员等级
#define KKWeb_VipLevel                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKMsg/VipLevel"]
//会员－会员活动
#define KKWeb_VipActive                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKMsg/VipActive"]
//设置－关于
#define KKWeb_About                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKMsg/About"]
//设置－帮助
#define KKWeb_Helper                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/KKMsg/Helper"]
//设置－意见反馈
#define KKWeb_Feedback                [NSString stringWithFormat:@"%@%@", HOST_HEADER, @"/Feedback"]









