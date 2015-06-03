//
//  AppDelegate.m
//  h5
//
//  Created by hf on 15/3/30.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "AppDelegate.h"
#import <SMS_SDK/SMS_SDK.h>
#import "MyNavigationController.h"
#import "RCIM.h"


//免费短信
#define SMSappKey @"61105df6a660"
#define SMSappSecret @"bab3f2aca52cbd9cbf1dd04628c56f51"

//融云
//#define appKeyIM @"mgb7ka1nbspfg"

#define appKeyIM @"8w7jv4qb70may"


//用户信息保存目录
NSString *userFolderPath;

@interface AppDelegate ()
{
    NSDictionary *userInfoDict;
    CLLocationManager *locationManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.currentlogingUser=[[CurrentUser alloc] init];
    //获取当前设备经纬度
    locationManager = [[CLLocationManager alloc] init];
    //设置代理为自己
    locationManager.delegate = self;
    if(IS_iOS8){
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //初始化短信，appKey和appSecret从后台申请得到
    [SMS_SDK registerApp:SMSappKey withSecret:SMSappSecret];
    
    //初始化融云IM,传入App Key，deviceToken 暂时为空,等待获取权限
    [RCIM initWithAppKey:appKeyIM deviceToken:nil];    //设置接收消息的监听器。
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    
    //初始化科大讯飞
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",KKAPPID_VALUE,TIMEOUT_VALUE];
    [IFlySpeechUtility createUtility:initString];
//    [IFlyFlowerCollector SetDebugMode:YES];
//    [IFlyFlowerCollector SetCaptureUncaughtException:YES];
//    [IFlyFlowerCollector SetAppid:KKAPPID_VALUE];
//    [IFlyFlowerCollector SetAutoLocation:YES];

    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //创建本地文件夹
    [self createFolder];
    
    //判断是否已登录
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    if ([saveDefaults objectForKey:@"isLogin"])
    {
        MyNavigationController *mnc;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        if([[saveDefaults objectForKey:@"isLogin"] isEqualToString:@"YES"])
        {
            //登录融云服务器获取Token
            [self connectToRCServer];
            
            //切换至主界面
            self.window.rootViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        }
        else
        {
            //切换至登录界面
            mnc = (MyNavigationController *)[[UINavigationController alloc]initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"]];
            mnc.navigationBar.barTintColor = [UIColor blackColor];
            mnc.navigationBar.tintColor = [UIColor whiteColor];
            mnc.navigationBar.barStyle = UIBarStyleBlack;
            self.window.rootViewController = mnc;
        }
    }
    
    
//#ifdef __IPHONE_8_0
//    // 在iOS8下注册苹果推送，申请推送权限。
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//#else
//    // IOS7以下
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
//#endif
    
    
//    edit by ken __IPHONE_7_1
    @try{
        
#ifdef __IPHONE_7_1    
    // IOS7以下
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
#else
    // 在iOS8下注册苹果推送，申请推送权限。
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
//    endedit
        NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    }
    @catch(NSException *exception)
    {
        NSLog(@"注册推送异常");
    }
    
    return YES;
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *urlStr = [NSString stringWithFormat:@"系统异常：错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
                        name,reason,[arr componentsJoinedByString:@"<br>"]];
    
//    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:url];
    [KKUtility showSystemErrorMsg:urlStr:nil];
    NSLog(@"%@",urlStr);  
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[RCIM sharedRCIM] getTotalUnreadCount];
    
    //勿扰时段内关闭本地通知
    [[RCIM sharedRCIM] getConversationNotificationQuietHours:^(NSString *startTime, int spansMin)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        
        if (startTime && startTime.length != 0)
        {
            NSDate *startDate = [dateFormatter dateFromString:startTime];
            NSDate *endDate = [startDate dateByAddingTimeInterval:spansMin * 60];
            NSString *nowDateString = [dateFormatter stringFromDate:[NSDate date]];
            NSDate *nowDate = [dateFormatter dateFromString:nowDateString];
            
            NSDate *earDate = [startDate earlierDate:nowDate];
            NSDate *laterDate = [endDate laterDate:nowDate];
            
            if (([startDate isEqualToDate:earDate] && [endDate isEqualToDate:laterDate]) || [nowDate isEqualToDate:startDate] || [nowDate isEqualToDate:earDate])
            {
                //设置本地通知状态为关闭
                [[RCIM sharedRCIM] setMessageNotDisturb:YES];
                
            }
            else
            {
                [[RCIM sharedRCIM] setMessageNotDisturb:NO];
            }
        }
    } errorCompletion:^(RCErrorCode status){
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:@"declineAction"])
    {
        
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
        
    }
}
#endif

// 获取苹果推送权限成功。
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken:%@",deviceToken);
    [[RCIM sharedRCIM] setDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"RemoteNote userInfo:[%@]",userInfo);
    NSLog(@"收到推送消息:[%@]", userInfo[@"aps"][@"alert"]);
}

//-----------------------------------创建本地文件夹,方便文件的管理-----------------------------------------------//
- (void)createFolder
{
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSString *userFolderPathTemp = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"UserInfo"];
    
    NSError *error = nil;
    BOOL isUserFolderCreate = [appFileManager fileExistsAtPath:userFolderPathTemp isDirectory:nil];
    if (!isUserFolderCreate)
    {
        NSString *oldFilePath = [[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"UserInfo"];
        BOOL isOldVersion = [appFileManager fileExistsAtPath:oldFilePath isDirectory:nil];
        if (isOldVersion)
        {
            userFolderPathTemp = oldFilePath;
        }
        else
        {
            if (![appFileManager createDirectoryAtPath:userFolderPathTemp withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"用户的文件创建失败");
                exit(-1);
            }
        }
    }
    
    //记录用户的文件夹的路径, 全局变量,如果为空表明初始化不成功;
    if (userFolderPath == nil)
    {
        userFolderPath = [userFolderPathTemp copy];
    }
    
    NSURL *url = [NSURL fileURLWithPath:userFolderPath];
    [self addSkipBackupAttributeToItemAtURL:url];
}

//返回该程序的档案目录
- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//设置云同步
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

//切换RootViewController
- (void)switchRootViewController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyNavigationController *mnc = (MyNavigationController *)[[UINavigationController alloc]initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    mnc.navigationBar.barTintColor = [UIColor blackColor];
    mnc.navigationBar.tintColor = [UIColor whiteColor];
    mnc.navigationBar.barStyle = UIBarStyleBlack;
    self.window.rootViewController = mnc;
}

//登录融云服务器获取Token
-(void)connectToRCServer
{
    //本地获取用户信息
    userInfoDict=[KKUtility getUserInfoFromLocalFile];
    NSLog(@"[AppDelegate]MsgToken[%@]", [userInfoDict objectForKey:@"MsgToken"]);
    
    //连接融云服务器
    [RCIM connectWithToken:[userInfoDict objectForKey:@"MsgToken"] completion:^(NSString *userId) {
        NSLog(@"[AppDelegate]Login successfully with userId: %@.", userId);
    } error:^(RCConnectErrorCode status) {
        NSLog(@"[AppDelegate]Login failed.");
    }];
}



//-----------------------------------------------RCIMReceiveMessageDelegate--------------------------------------//
//接收消息的监听器
-(void)didReceivedMessage:(RCMessage *)message left:(int)nLeft
{
    if (0 == nLeft)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"AppDelegate未读[%d]", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]);
            if([[RCIM sharedRCIM] getTotalUnreadCount] > 0)
            {
                [UIApplication sharedApplication].applicationIconBadgeNumber = [[RCIM sharedRCIM] getTotalUnreadCount];
                [[self.mainTabBarController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d", (UInt16)[[RCIM sharedRCIM] getTotalUnreadCount]];
            }
        });
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.currentlogingUser.Location =newLocation;
    self.currentlogingUser.Longitude=[NSString stringWithFormat:@"%.4f",newLocation.coordinate.longitude];
    self.currentlogingUser.Latitude=[NSString stringWithFormat:@"%.4f",newLocation.coordinate.latitude];    
    //根据经纬度反向地理编译出地址信息    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}
@end







































