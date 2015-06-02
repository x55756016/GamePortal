//
//  Utility.h
//  ＋
//
//  Created by Administrator on 15/5/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#ifndef __Utility_h
#define __Utility_h


#endif
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CurrentUser.h"

@interface KKUtility:NSObject

+(NSDictionary*)getUserInfoFromLocalFile;

+(NSString *)intervalSinceNow: (NSString *) theDate;

#pragma clang diagnostic ignored "-Wmissing-selector-name"
+(NSString*)getUserDistinctFromMyPoint:(NSDictionary*)dStartUser:(CurrentUser *)LoginUser;

#pragma clang diagnostic ignored "-Wmissing-selector-name"
+(NSString*)calcutDistinct:(CLLocation*)kkStartPotint:(CLLocation*)kkEndPotint;

+(UIImage *)getImageFromLocal:(NSString *)imageName;

+(void)saveImageToLocal:(UIImage *)image:(NSString*)imageName;

+(NSString *)getImagePath:(NSString*)path:(NSString*)strType;

//记录错误日志
+(void)logSystemErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error;
//显示系统错误
+(void)showSystemErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error;
//显示网络错误
+(void)showHttpErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error;

//保存好友信息至本地
+(void)saveFriendsToLocal:(NSArray *)FriendsArray:(NSString *)UserId;
//从本地获取好友信息
+(NSArray*)GetFriendsFromLocal:(NSString*)UserId;
//弹出提示框
+(void)justAlert:(NSString*)Message;
//保存当前用户信息至本地
+(void)saveUserInfo:(NSDictionary *)userInfoDir;
//显示view 位置及大小
+(void)showViewGrenct:(UIView*) tmpview:(NSString*)viewName;
@end