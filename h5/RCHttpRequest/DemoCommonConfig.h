//
//  CommonConfig.h
//  RongCloud
//
//  Created by Heq.Shinoda on 14-5-19.
//  Copyright (c) 2014年 iOS-IMKit-Demo. All rights reserved.
//

#ifndef RongCloud_CommonConfig_h
#define RongCloud_CommonConfig_h


#define DEV_FAKE_SERVER @"http://119.254.110.241:8080/"  //Beijing SUN-QUAN  测试环境（北京）
#define PRO_FAKE_SERVER @"http://119.254.110.79:8080/"  //Beijing Liu-Bei    线上环境（北京）
//#define PRO_FAKE_SERVER @"http://119.254.108.131:8080/"  //Beijing Zhang-Fei    线上测试环境（北京）


#define RC_APPKEY_CONFIGFILE @"AppKeyConfig"


#define CHECK_PASSWORD_ENABLE 0

//当前版本
#define IOS_FSystenVersion            ([[[UIDevice currentDevice] systemVersion] floatValue])
#define IOS_DSystenVersion            ([[[UIDevice currentDevice] systemVersion] doubleValue])
#define IOS_SSystemVersion            ([[UIDevice currentDevice] systemVersion])

//当前语言
#define CURRENTLANGUAGE           ([[NSLocale preferredLanguages] objectAtIndex:0])


//是否Retina屏
#define isRetina                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) :NO)
//是否iPhone5
#define ISIPHONE                  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define ISIPHONE5                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


//-----------Notification-Macro Definination---------//
#define KNotificaitonPreviewPiecture @"KNotificaitonPreviewPiecture"
#define KNotificationCellReceiveNotification @"KNotificationCellReceiveNotification"

#endif//RongCloud_CommonConfig_h



