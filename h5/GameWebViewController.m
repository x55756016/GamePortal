//
//  GameWebViewController.m
//  h5
//
//  Created by hf on 15/4/15.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "GameWebViewController.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "h5kkContants.h"
#import "KKUtility.h"
#import "CurrentUser.h"
#import "HEXCMyUIButton.h"


#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlyContact.h"
#import "iflyMSC/IFlyDataUploader.h"
#import "SBJson4.h"
#import "Microphone.h"


@interface GameWebViewController (){
    
    BOOL flag; //控制tabbar的显示与隐藏标志
    HEXCMyUIButton *myButton;
    UIView *TopBarView;
    UIView *ButtomBarView;

    NSDictionary *userInfo;
    
    enum WXScene _scene;
    UIImage *sendImage;//游戏截图
    NSString *currentTimeStr;//时间戳
    
    NSLayoutConstraint *ButtomHeightconstraint;//底部栏高度，由于有文本输入框所以要调整高度。
    
    NSString *landorprot;//是否横屏显示
    
    ASIFormDataRequest *request;
    
    bool needAddMenuBar;//控制是否要初始化游戏菜单
    
    Microphone *kkMicrophone;
    
    
    bool isSettingStatusBar;

}
@end

@implementation GameWebViewController

@synthesize delegate = _delegate;
@synthesize gameWebView;

- (void)viewDidLoad
{
    @try {
        
        [super viewDidLoad];
        [self regkeyNotification];
        [WXApi registerApp:KKWebChartAppid];
        userInfo=[KKUtility getUserInfoFromLocalFile];
        
        self.gameWebView.scrollView.scrollEnabled=false;//禁止滚动
        
        //科大讯飞创建语音听写的对象
        // 创建识别对象
        self.iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        //请不要删除这句,createRecognizer是单例方法，需要重新设置代理
        self.iFlySpeechRecognizer.delegate = self;
        [self.iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //设置采样率
        //    [iflySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置录音保存文件
        //    [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        //设置为非语义模式
        [self.iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
        //设置返回结果的数据格式，可设置为json，xml，plain，默认为json。
        //前端点检测；静音超时时间，即用户多长时间不说话则当做超时处理
        [self.iFlySpeechRecognizer setParameter:@"10000" forKey:@"vad_bos"];
        [self.iFlySpeechRecognizer setParameter:@"10000" forKey:@"vad_eos"];
        [self.iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
        //设置为麦克风输入模式
        [self.iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        kkMicrophone=[[Microphone alloc] init];
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
}
-(void)viewWillAppear:(BOOL)animated
{        //恢复状态栏方向
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态
    isSettingStatusBar=false;
    self.view.transform =CGAffineTransformIdentity;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.tabBarController.tabBar.hidden=YES;
    
    needAddMenuBar=true;
    [self GetGameInfoFromServer];
    [self SendPlayGameInfoToServer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    kkAppDelegate.currentlogingUser.currentGamedirection=[NSNumber numberWithInteger:0];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态
    self.view.transform =CGAffineTransformIdentity;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //科大讯飞取消识别
    [self.iFlySpeechRecognizer cancel];
    [self.iFlySpeechRecognizer setDelegate: nil];
    [kkMicrophone stopMicrophone];
    [self unregkeyNotification];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //恢复状态栏方向
    isSettingStatusBar=NO;
//    [super viewWillDisappear:NO];
    self.tabBarController.tabBar.hidden=NO;
}
//屏幕旋转完成事件
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    myButton.frame = CGRectMake(0, 180, 40, 40);
}

//－－－－－－－－－－－－－－－－－－－－－微信接口－－－－－－－－－－－－－－－－－－－－－
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}
//－－－－－－－－－－－－－－－－－－－－－结束微信接口－－－－－－－－－－－－－－－－－－－

-(void)addLeftAndRightMenu
{
    @try {
        //tab bar view  始终居中显示
        //    TopBarView = [[UIView alloc] init] ;
        TopBarView= (UIView *)[[[NSBundle mainBundle]loadNibNamed:@"TopMenuView" owner:self options:nil]objectAtIndex:0];
        //[[TopBarView alloc] initWithNibName:@"TopMenuView" bundle:nil];
        //view 设置半透明 圆角样式
//        TopBarView.layer.cornerRadius = 10;//设置圆角的大小
        TopBarView.layer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 ] CGColor];
        TopBarView.layer.masksToBounds = YES;
        TopBarView.translatesAutoresizingMaskIntoConstraints=NO;
        TopBarView.layer.borderColor = [UIColor blackColor].CGColor;
        TopBarView.layer.borderWidth = 0.1;
        TopBarView.hidden=YES;
        [self.view addSubview:TopBarView];
        //设置坐标点在x轴中心位置
        NSLayoutConstraint *Pointconstraint = [NSLayoutConstraint constraintWithItem:TopBarView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [self.view addConstraint:Pointconstraint];
        //高度
        NSLayoutConstraint *TopHeightconstraint = [NSLayoutConstraint constraintWithItem:TopBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
        [self.view addConstraint:TopHeightconstraint];
        //距离父视图上面1个点
        NSLayoutConstraint *Topconstraint = [NSLayoutConstraint constraintWithItem:TopBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:1.0f];
        [self.view addConstraint:Topconstraint];
        //距离父视图右边1个点
        NSLayoutConstraint *TopRightconstraint = [NSLayoutConstraint constraintWithItem:TopBarView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        [self.view addConstraint:TopRightconstraint];
        //距离父视图左边1个点
        NSLayoutConstraint *Leftconstraint = [NSLayoutConstraint constraintWithItem:TopBarView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        [self.view addConstraint:Leftconstraint];
       
        //退出
        UIButton *exitBtn=(UIButton *)[TopBarView viewWithTag:1];
        [exitBtn addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
        //开启关闭弹幕
        UIButton *msgSwichBtn=(UIButton *)[TopBarView viewWithTag:2];
        [msgSwichBtn addTarget:self action:@selector(SwitchMsgPush:) forControlEvents:UIControlEventTouchUpInside];
        //分享
        UIButton *shareBtn=(UIButton *)[TopBarView viewWithTag:3];
        [shareBtn addTarget:self action:@selector(ShareInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //buttom 工具栏
        ButtomBarView= (UIView *)[[[NSBundle mainBundle]loadNibNamed:@"ButtomMenuView" owner:self options:nil]objectAtIndex:0];
        //view 设置半透明 圆角样式
//        ButtomBarView.layer.cornerRadius = 10;//设置圆角的大小
        ButtomBarView.layer.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5 ] CGColor];
        
        ButtomBarView.layer.masksToBounds = YES;
        ButtomBarView.translatesAutoresizingMaskIntoConstraints=NO;
        ButtomBarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        ButtomBarView.layer.borderWidth = 0.1;

        ButtomBarView.hidden=YES;
        [self.view addSubview:ButtomBarView];
        //设置坐标点在x轴中心位置
        Pointconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [self.view addConstraint:Pointconstraint];
        //高度
        ButtomHeightconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
        [self.view addConstraint:ButtomHeightconstraint];
        //距离父视图底线1个点
        NSLayoutConstraint *Buttomconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-1.0f];
        [self.view addConstraint:Buttomconstraint];
        //距离父视图右边1个点
        TopRightconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        [self.view addConstraint:TopRightconstraint];
        //距离父视图左边1个点
        Leftconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        [self.view addConstraint:Leftconstraint];

        
        
        self.textMsgField=(UITextField *)[ButtomBarView viewWithTag:1];
        self.textMsgField.delegate=self;
        //语音
        UIButton *startVoiceBtn=(UIButton *)[ButtomBarView viewWithTag:2];
        //    [startVoiceBtn setImage:[UIImage imageNamed:@"k_voice_default.png"] forState:UIControlStateNormal];
        //    [startVoiceBtn setImage:[UIImage imageNamed:@"k_voice_pressed.png"] forState:UIControlStateHighlighted];
//        [startVoiceBtn addTarget:self action:@selector(StartVioceMsg:) forControlEvents:UIControlEventTouchUpInside];
        //实例化长按手势监听
        UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleTableviewCellLongPressed:)];
        //代理
        longPress.delegate = self;
        longPress.minimumPressDuration = 0.2;
        //将长按手势添加到需要实现长按操作的视图里
        [startVoiceBtn addGestureRecognizer:longPress];
        
        
        //发送
        UIButton *btnSend=(UIButton *)[ButtomBarView viewWithTag:3];
        //    [btnSend setImage:[UIImage imageNamed:@"play_btn_send.png"] forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(sendJsFunction:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
    


}

//------------------启动科大讯飞及相关接口------------------------------------------------------------
//长按事件的实现方法
- (void) handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    @try {
        if (gestureRecognizer.state ==
            UIGestureRecognizerStateBegan) {
            // NSLog(@"UIGestureRecognizerStateBegan");
            [self returnButtomHeightconstraint];
            //启动科大讯飞合成会话
            bool ret = [self.iFlySpeechRecognizer startListening];
            if (ret) {
                [kkMicrophone showMicrophone];
                if([landorprot isEqualToString:@"1"])
                {
                    [kkMicrophone Transform:M_PI/2];
                }
            }
        }
        if (gestureRecognizer.state ==
            UIGestureRecognizerStateChanged) {
            //NSLog(@"UIGestureRecognizerStateChanged");
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            //NSLog(@"UIGestureRecognizerStateEnded");
            [self.iFlySpeechRecognizer stopListening];
            [kkMicrophone stopMicrophone];
        }
    }
    @catch (NSException *exception) {
    
    }
    
}

- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    //NSLog(@"听写结果：%@",resultString);
    NSString * resultFromJson =  [self getResultFromJson:resultString];
    
    self.textMsgField.text =[NSString stringWithFormat:@"%@%@", self.textMsgField.text,resultFromJson];
    
    NSLog(@"isLast=%d",isLast);
    
}
- (void) onVolumeChanged: (int)volume{
    float volumeNum=(float)volume/30;
    NSLog(@"volume=%d",volume);
    
    [kkMicrophone updateVoiceVolume:volumeNum];
    
}
- (void) onEndOfSpeech
{
    [kkMicrophone stopMicrophone];
}
- (void) onError:(IFlySpeechError *) error
{
    NSString *text ;
    if (error.errorCode ==0 ) {
        
        if (self.textMsgField.text.length==0) {
            
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
}
-(NSString *) getResultFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    
    //返回的格式必须为utf8的,否则发生未知错误
    NSString *jsonString = params;
    
    id block = ^(id obj, BOOL *ignored) {
        NSDictionary *dic = obj;
        
        NSArray *wordArray = [dic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
        
    };
    
    id eh = ^(NSError *err) {
        NSLog(@"json parser error");
        //        self.output.string = err.description;
    };
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    [parser parse:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return tempStr;
}

//-------------------结束科大讯飞-----------------------------------------------------------


//做了修改 设置tab bar
- (void)addMenuButton
{
    @try {
        if(myButton==nil){
        myButton = [HEXCMyUIButton buttonWithType:UIButtonTypeCustom];
        myButton.MoveEnable = YES;
        myButton.frame = CGRectMake(0, 180, 40, 40);
        //TabBar上按键图标设置
        [myButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"game_mianBtnNormal.png"]] forState:UIControlStateNormal];
        [myButton setImage:[UIImage imageNamed:@"game_mianBtnWaiting.png"] forState:UIControlStateSelected];
        [myButton setImage:[UIImage imageNamed:@"game_mianBtnSelected.png"] forState:UIControlStateHighlighted];
        [myButton setTag:10];
        flag = NO;//控制tabbar的显示与隐藏标志 NO为隐藏
        [myButton addTarget:self action:@selector(tabbarbtn:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:myButton];
        [self.view bringSubviewToFront: myButton];
        
        CGRect  frame=myButton.frame;
        NSLog(@"%f,%f,%f,%f",frame.origin.x, frame.origin.y ,frame.size.width,frame.size.height);
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }

}
//显示 隐藏tabbar
- (void)tabbarbtn:(HEXCMyUIButton*)btn
{
    if(needAddMenuBar){
        
        [self addLeftAndRightMenu];
//        if(IS_iOS8){
//            if([landorprot isEqualToString:@"1"])
//            {
//                [KKUtility justAlert:@"点击左小角声音图标可直接通过语音输入文字，快试试吧！"];
//            }
//        }
        needAddMenuBar=false;
        [self.view bringSubviewToFront: myButton];
    }
    UITextField *textFiled=(UITextField *)[ButtomBarView viewWithTag:1];
    [textFiled resignFirstResponder];
    [self returnButtomHeightconstraint];
    //在移动的时候不触发点击事件
    if (!btn.MoveEnabled) {
        if(!flag){
            TopBarView.hidden = NO;
            ButtomBarView.hidden=NO;
            flag = YES;
        }else{
            TopBarView.hidden = YES;
            ButtomBarView.hidden=YES;
            flag = NO;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//------------------------------开始获取游戏详情-----------------
-(void)GetGameInfoFromServer
{
    NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];
    
    
    NSString *urlStr = Get_GameDetailInfo;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:15.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:gameId forKey:@"pageId"];
    [request setDidFailSelector:@selector(GetGameInfoFromServerFail:)];
    [request setDidFinishSelector:@selector(GetGameInfoFromServerFinish:)];
    [request startAsynchronous];
    
}
- (void)GetGameInfoFromServerFinish:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    //    NSLog(@"requestUserGame[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        NSArray *data= [dic objectForKey:@"ObjData"];
        self.gameDetailDict =[data objectAtIndex:0];
        NSLog(@"GameInfoDetail%@", self.gameDetailDict);
    }
    
    landorprot = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ScreenType"]];
    if([landorprot isEqualToString:@"1"])
    {
        NSLog(@"需要强制横屏");
        [UIView beginAnimations:@"changeToLandscapeMode" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5f];
        
        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        float width=self.view.frame.size.width;
        float height=self.view.frame.size.height;
        
        self.view.bounds = CGRectMake(0, 0, width, height);
        [UIView commitAnimations];
        isSettingStatusBar=YES;
        if(IS_iOS8){
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGRect rect=CGRectMake(0, 0, MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
            
        }
        
        AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        kkAppDelegate.currentlogingUser.currentGamedirection=[NSNumber numberWithInteger:1];
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];  //设置状态栏横屏
        
    }
    else
    {
        AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        kkAppDelegate.currentlogingUser.currentGamedirection=[NSNumber numberWithInteger:0];
       [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait]; //设置竖屏
        NSLog(@"不需要强制横屏");
    }
    
    NSString *urlStr = [self.gameDetailDict objectForKey:@"Url"];
    NSString *reqStr = [NSString stringWithFormat:@"%@?UserId=%@&userkey=%@", urlStr,
                        [userInfo objectForKey:@"UserId"],
                        [userInfo objectForKey:@"UserKey"]];
    reqStr = [reqStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"游戏url[%@]", reqStr);
    
    NSURL *url = [NSURL URLWithString:reqStr];
    NSURLRequest *requestUrl=[NSURLRequest requestWithURL:url];
    [self.gameWebView loadRequest:requestUrl];
    NSLog(@"GetGameInfoFromServerFinish");
    
    NSDictionary *gamedic= self.gameDetailDict;
    [self addMyGameToServer:gamedic];
    
    [self addMenuButton];
}
- (void)GetGameInfoFromServerFail:(ASIHTTPRequest *)req
{
    [self addMenuButton];
    [KKUtility showHttpErrorMsg:@"获取游戏详情失败 " :req.error];
}
//---------------------------结束获取游戏详情---------

//----------------------------添加我的游戏完成事件－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－


-(void)addMyGameToServer:(NSDictionary *)addGameDict
{
    NSLog(@"开始游戏[%@]", addGameDict);
    
    //用户点击开始后，把这个游戏加入到他玩过的游戏中
    NSString *urlStr = ADD_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self.delegate];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [addGameDict objectForKey:@"ContentPageID"]] forKey:@"GameId"];
    [request setDidFailSelector:@selector(addGameFail:)];
    [request setDidFinishSelector:@selector(addGameFinish:)];
    [request startAsynchronous];
    
//    [self.delegate addGameConfigComplete:@"addMyGameToServer Finish!"];
    
}

- (void)addGameFinish:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFinish");
}

- (void)addGameFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"添加我玩过的游戏失败 " :req.error];
}

//----------------------------结束添加我的游戏完成事件－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－



- (IBAction)exitAction:(id)sender
{
    CGRect rect=  [[UIScreen mainScreen]bounds];
    [KKUtility showViewGrenct:nil :nil];
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"确定要退出?"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
   
    
    [alert show];
}

//--------------------------UIAlertViewDelegate-------------------------//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

//---------------------------UIWebViewDelegate--------------------------//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [KKUtility showHttpErrorMsg:nil :error];
}


//------------------------------发送游戏动态给服务器
-(void)SendPlayGameInfoToServer
{
    NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];

    
    NSString *urlStr = USER_AddKKAround;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:@"0" forKey:@"AreaId"];
    [request setPostValue:gameId forKey:@"GameId"];
    
     AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    [request setPostValue:kkAppDelegate.currentlogingUser.Longitude forKey:@"lon"];//经度
    [request setPostValue:kkAppDelegate.currentlogingUser.Latitude forKey:@"lat"];//纬度

    
    [request setDidFailSelector:@selector(SendPlayGameInfoFail:)];
    [request setDidFinishSelector:@selector(SendPlayGameInfoFinish:)];
    [request startAsynchronous];
}

- (void)SendPlayGameInfoFinish:(ASIHTTPRequest *)request
{
    NSLog(@"SendPlayGameInfoFinish");
}

- (void)SendPlayGameInfoFail:(ASIHTTPRequest *)req
{
     [KKUtility showHttpErrorMsg:@"发送游戏动态失败 " :req.error];
}
//------------------------------------

//uitextfile 事件开始---------------------------------------
- (void)regkeyNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)unregkeyNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    float fY =0;
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationLandscapeLeft:
          fY= 40 + keyboardSize.width; //横屏高度变成宽度了
            break;
            
        case UIDeviceOrientationLandscapeRight:
           fY= 40 + keyboardSize.width; //横屏高度变成宽度了
            break;
            default:
            fY= 40 + keyboardSize.height;
            break;
    }
    [self.view removeConstraint:ButtomHeightconstraint];
    ButtomHeightconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:fY];
    [self.view addConstraint:ButtomHeightconstraint];
    myButton.frame = CGRectMake(20, 20, 40, 40);
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITextField *textFiled=(UITextField *)[ButtomBarView viewWithTag:1];
    [textFiled resignFirstResponder];
    [self returnButtomHeightconstraint];

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self returnButtomHeightconstraint];
    [textField resignFirstResponder];
    

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self returnButtomHeightconstraint];
}

-(void)returnButtomHeightconstraint
{
    //还原
    float fY = 40;
    [self.view removeConstraint:ButtomHeightconstraint];
    ButtomHeightconstraint = [NSLayoutConstraint constraintWithItem:ButtomBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:fY];
    [self.view addConstraint:ButtomHeightconstraint];
}
//uitextfile 事件结束---------------------------------------


//发送弹幕
- (IBAction)sendJsFunction:(id)sender
{
    if([self.textMsgField.text isEqualToString:@""])
    {
        return;
    }
    NSString *type=@"1";
    NSString *area=@"房间";
    NSString *nickname=[userInfo objectForKey:@"NickName"];
    NSString *msg=self.textMsgField.text;
    NSString *jsFuncStr = [NSString stringWithFormat:@"%@%@,'%@','%@','%@'%@",@"CW.DanmuManager.getInstance().playDanMu(",type,area,nickname,msg,@");"];
//    jsFuncStr =@"CW.DanmuManager.getInstance().playDanMu(1, '房间', 'kk小助手', '111欢迎来到kk玩，使用语音发送弹幕聊天吧：）');";
    [gameWebView stringByEvaluatingJavaScriptFromString:jsFuncStr];
    NSLog(@"Send jsFuncStr:%@",jsFuncStr);
    self.textMsgField.text=@"";
}
//开启关闭弹幕
- (IBAction)SwitchMsgPush:(id)sender
{
     NSString *OpenMsgInfo;
    UIButton *btn=(UIButton*)sender;
    if([btn.currentTitle isEqualToString:@"开启字幕"])
    {
        OpenMsgInfo=@"1";
        [btn setTitle:@"关闭字幕" forState:UIControlStateNormal];
    }
    else{
        OpenMsgInfo=@"0";
         [btn setTitle:@"开启字幕" forState:UIControlStateNormal];
    }
    NSString *jsFuncStr = [NSString stringWithFormat:@"%@'%@'%@",@"CW.DanmuManager.getInstance().changeDanmuState(",OpenMsgInfo,@");"];
    [gameWebView stringByEvaluatingJavaScriptFromString:jsFuncStr];
    NSLog(@"Send jsFuncStr:%@",jsFuncStr);
}
//分享微信－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
- (IBAction)ShareInfo:(id)sender
{
    UIActionSheet *acSheet = [[UIActionSheet alloc]initWithTitle:@"你要分享到哪里？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"我的荣誉墙", nil];
    acSheet.tag =1;
    acSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [acSheet showInView:[[UIApplication sharedApplication]keyWindow]];
    [acSheet showInView:self.view];
}

#pragma mark - uiactionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==1) {
        if (buttonIndex == 0) {
            UIActionSheet *acSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给微信好友",@"分享到朋友圈", nil];
            acSheet.tag =2;
            acSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [acSheet showInView:self.view];
            
        }
        else if (buttonIndex == 1) {
            //分享到我的荣誉墙
            [self upLoadGameImageToServer];
        }
    }
    else if (actionSheet.tag==2){
        if (buttonIndex == 0) {
            
            [self changeScene:WXSceneSession];
            [self sendLinkContent];
            
        }
        else if (buttonIndex == 1) {
            
            [self changeScene:WXSceneTimeline];
            [self sendLinkContent];
            
        }
        
    }
    
}
#pragma mark - View lifecycle
- (void)sendMusicContent
{
    
}

- (void)sendVideoContent
{
}

- (void)sendImageContent
{

}



- (void)sendLinkContent
{
    NSString *gameTitle=[self.gameDetailDict objectForKey:@"Title"];
    NSString *strShareTitle = [NSString stringWithFormat:@"%@%@%@",@"我在KK玩, 快来和我一起玩<",gameTitle,@">"];
    
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = strShareTitle;
        message.description = @"KK玩, 中国第一同城游戏交友平台";
        [message setThumbImage:[self screenShot]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
         NSString *urlStr = [self.gameDetailDict objectForKey:@"Url"];
//        ext.webpageUrl = @"http://www.h5kk.com/cms/DownLoad";
        ext.webpageUrl = urlStr;
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        
        [WXApi sendReq:req];
    }else{
        UIAlertView *alView = [[UIAlertView alloc]initWithTitle:@"" message:@"你的iPhone上还没有安装微信,无法使用此功能，使用微信可以方便的把你喜欢的作品分享给好友。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"免费下载微信", nil];
        [alView show];
        
    }
}
-(UIImage*)screenShot
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    sendImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(sendImage, nil, nil, nil);//保存图片到照片库
    return  sendImage;
    
}

-(void) changeScene:(NSInteger)scene{
    _scene = scene;
}

//结束微信分享－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

//荣誉墙分享－－－－－－－－－－－－－－－－－－－－－－－----------------------------------------------------------------------
//上传截图至服务器
-(void)upLoadGameImageToServer
{
    UIImage *headImage = [self screenShot];
    NSData *uploadImageData = UIImageJPEGRepresentation(headImage, 0.1);
    //时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMddHHmmmm"];
    currentTimeStr = [df stringFromDate:currentDate];
    //userid
    NSString *useridStr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]];
    NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"http://pic.h5kk.com/fileupload.php?id=%@&index=%@&game=%@", useridStr, currentTimeStr,gameId];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:20.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setDidFailSelector:@selector(upLoadGameImageToServerFail:)];
    [request setDidFinishSelector:@selector(upLoadGameImageToServerFinish:)];
    [request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
    [request addData:uploadImageData forKey:@"upfile"];
    [request startAsynchronous];
}

- (void)upLoadGameImageToServerFinish:(ASIHTTPRequest *)req
{
    NSLog(@"上传荣誉墙图片成功");
    @try
    {
        NSError *error;
        NSData *responseData = [req responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        NSNumber *picPath=[dic objectForKey:@"Name"];
       if([picPath intValue]==1)
       {
           NSString *useridStr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]];
           NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];

           NSString *picPath=[NSString stringWithFormat:@"%@%@/%@/pic_%@.jpg",@"http://pic.h5kk.com/uploadimg/",useridStr,gameId,currentTimeStr];
           
           [self upDataGamePicImage:picPath];
       }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}
- (void)upLoadGameImageToServerFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"上传荣誉墙图片失败 " :req.error];
}


//更新至数据 服务器
-(void)upDataGamePicImage:(NSString*)picPath
{
    NSString *urlStr = ADD_GameAchievement;
    NSURL *url = [NSURL URLWithString:urlStr];
     NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    
    [request setPostValue:[NSString stringWithFormat:@"%@",gameId] forKey:@"GameId"];
    [request setPostValue:[NSString stringWithFormat:@"%@",picPath] forKey:@"PicPath"];
    
    [request setPostValue:@"1" forKey:@"pageindex"];
    [request setDidFailSelector:@selector(upDataGamePicImageFail:)];
    [request setDidFinishSelector:@selector(upDataGamePicImageFinish:)];
    [request startAsynchronous];
}

- (void)upDataGamePicImageFinish:(ASIHTTPRequest *)request
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"分享荣誉墙成功！"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    [alert show];

    NSLog(@"更新荣誉墙成功");
}

- (void)upDataGamePicImageFail:(ASIHTTPRequest *)req
{
     [KKUtility showHttpErrorMsg:@"更新荣誉墙失败 " :req.error];
}
//-------------结束荣誉墙分享----------------------------------------------------------------------------------------------------

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}

-(BOOL)shouldAutorotate
{
    if(isSettingStatusBar)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//- (void)hidesTabBar:(BOOL)hidden{
//    
//    
//         [UIView beginAnimations:nil context:NULL];
//         [UIView setAnimationDuration:0];
//    
//         for (UIView *view in self.tabBarController.view.subviews) {
//                if ([view isKindOfClass:[UITabBar class]]) {
//                      if (hidden) {
//                                [view setFrame:CGRectMake(view.frame.origin.x, [UIScreen mainScreen].bounds.size.height, view.frame.size.width , view.frame.size.height)];
//                
//                            }else{
//                                   [view setFrame:CGRectMake(view.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 49, view.frame.size.width, view.frame.size.height)];
//                    
//                                }
//                }else{
//                      if([view isKindOfClass:NSClassFromString(@"UITransitionView")]){
//                                if (hidden) {
//                                         [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
//                                 }else{
//                                           [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 49 )];
//                                     
//                                       }
//                                }
//                        }
//             }
//         [UIView commitAnimations];
//    
//    }
@end































