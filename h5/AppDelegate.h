//
//  AppDelegate.h
//  h5
//
//  Created by hf on 15/3/30.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCIM.h"
#import "RCHttpRequest.h"
#import "DemoCommonConfig.h"
#import "MainTabBarController.h"
#import "CurrentUser.h"
#import "h5kkContants.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "IFlyFlowerCollector.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCIMReceiveMessageDelegate,CLLocationManagerDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabBarController *mainTabBarController;
@property (strong, nonatomic) CurrentUser *currentlogingUser;

//@property (strong, nonatomic) CLLocationManager *locationManager;


//切换RootViewController
- (void)switchRootViewController;

//返回该程序的档案目录
- (NSString *)applicationDocumentsDirectory;

@end

