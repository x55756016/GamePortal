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
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlyRecognizerView.h"

@interface GameWebViewController (){
    
    BOOL flag; //控制tabbar的显示与隐藏标志
    HEXCMyUIButton *myButton;
    UIView *TopBarView;
    UIView *ButtomBarView;
    IFlySpeechSynthesizer * _iFlySpeechSynthesizer;
    NSDictionary *userInfo;
    
    enum WXScene _scene;
    UIImage *sendImage;//游戏截图
    NSString *currentTimeStr;//时间戳
    
    NSLayoutConstraint *ButtomHeightconstraint;//底部栏高度，由于有文本输入框所以要调整高度。
    
    NSString *landorprot;//是否横屏显示
    
    ASIFormDataRequest *request;

}
@end

@implementation GameWebViewController

@synthesize delegate = _delegate;
@synthesize gameWebView;

- (void)viewDidLoad
{
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];  //设置状态栏

    [super viewDidLoad];
    [self regkeyNotification];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [WXApi registerApp:@"wx6f12d1a412f2bf36"];
    
    //创建语音听写的对象
    self.iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    
    //delegate需要设置，确保delegate回调可以正常返回
    _iflyRecognizerView.delegate = self;
    userInfo=[KKUtility getUserInfoFromLocalFile];
    
    [self SendPlayGameInfoToServer];
    [self GetGameInfoFromServer];
    [self addLeftAndRightMenu];
    [self addMenuButton];
    

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //终止识别
    [_iflyRecognizerView cancel];
    [_iflyRecognizerView setDelegate:nil];
    [self unregkeyNotification];

}
//屏幕旋转完成事件
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    myButton.frame = CGRectMake(0, 150, 40, 40);
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
        TopBarView.layer.cornerRadius = 10;//设置圆角的大小
        TopBarView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        //    TopBarView.alpha = 0.5f;//设置透明
        TopBarView.layer.masksToBounds = YES;
        TopBarView.translatesAutoresizingMaskIntoConstraints=NO;
        TopBarView.layer.borderColor = [UIColor whiteColor].CGColor;
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
        ButtomBarView.layer.cornerRadius = 10;//设置圆角的大小
        ButtomBarView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        //  ButtomBarView.alpha = 0.5f;//设置透明
        ButtomBarView.layer.masksToBounds = YES;
        ButtomBarView.translatesAutoresizingMaskIntoConstraints=NO;
        ButtomBarView.layer.borderColor = [UIColor whiteColor].CGColor;
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
        [startVoiceBtn addTarget:self action:@selector(StartVioceMsg:) forControlEvents:UIControlEventTouchUpInside];
        
        //发送
        UIButton *btnSend=(UIButton *)[ButtomBarView viewWithTag:3];
        //    [btnSend setImage:[UIImage imageNamed:@"play_btn_send.png"] forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(sendJsFunction:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    @catch (NSException *exception) {
        [KKUtility showSystemErrorMsg:exception.reason :nil];
    }
    


}



//做了修改 设置tab bar
- (void)addMenuButton
{
    myButton = [HEXCMyUIButton buttonWithType:UIButtonTypeCustom];
    myButton.MoveEnable = YES;
    myButton.frame = CGRectMake(0, 150, 40, 40);
    //TabBar上按键图标设置
    [myButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"k_default.png"]] forState:UIControlStateNormal];
    [myButton setImage:[UIImage imageNamed:@"k_pressed.png"] forState:UIControlStateHighlighted];
    [myButton setTag:10];
    flag = NO;//控制tabbar的显示与隐藏标志 NO为隐藏
    [myButton addTarget:self action:@selector(tabbarbtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myButton];
}
//显示 隐藏tabbar
- (void)tabbarbtn:(HEXCMyUIButton*)btn
{
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
    
//    landorprot = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ScreenType"]];
//    if([landorprot isEqualToString:@"1"])
//    {
//        NSLog(@"需要强制横屏");
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];  //设置状态栏
//        [UIView beginAnimations:@"changeToLandscapeMode" context:nil];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDuration:0.5f];
//        self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        [UIView commitAnimations];
//    }
//    else
//    {
//        NSLog(@"不需要强制横屏");
//    }
    
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
    
}
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

- (void)GetGameInfoFromServerFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取游戏详情失败 " :req.error];
}
//---------------------------结束获取游戏详情---------

- (IBAction)exitAction:(id)sender
{
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
        [self.navigationController popViewControllerAnimated:YES];
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
    [textField resignFirstResponder];
    
    [self returnButtomHeightconstraint];

    return YES;
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


- (IBAction)StartVioceMsg:(id)sender
{
    [self returnButtomHeightconstraint];
    [_iflyRecognizerView setParameter: @"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //设置结果数据格式，可设置为json，xml，plain，默认为json。
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    [_iflyRecognizerView start];
    
    NSLog(@"start listenning...");

}

#pragma mark IFlyRecognizerViewDelegate

/** 识别结果回调方法
 @param resultArray 结果列表
 @param isLast YES 表示最后一个，NO表示后面还有结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    self.textMsgField.text = [NSString stringWithFormat:@"%@%@",self.textMsgField.text,result];
}

/** 识别结束回调方法
 @param error 识别错误
 */
- (void)onError:(IFlySpeechError *)error
{
    NSLog(@"errorCode:%d",[error errorCode]);
}
//------------------------------------------------------------------------------

//发送弹幕
- (IBAction)sendJsFunction:(id)sender
{
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
    UIActionSheet *acSheet = [[UIActionSheet alloc]initWithTitle:@"你要分享到哪里？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"我的战绩墙", nil];
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
            //分享到我的战绩墙
            [self upLoadGameImageToServer];
        }
    }
    else if (actionSheet.tag==2){
        if (buttonIndex == 0) {
            [self sendLinkContent];
            [self changeScene:WXSceneSession];
            
        }
        else if (buttonIndex == 1) {
            [self sendLinkContent];
            [self changeScene:WXSceneTimeline];
            
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
        ext.webpageUrl = @"http://www.h5kk.com/cms/DownLoad";
        
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

//战绩墙分享－－－－－－－－－－－－－－－－－－－－－－－----------------------------------------------------------------------
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
    NSLog(@"上传战绩图片成功");
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
    [KKUtility showHttpErrorMsg:@"上传战绩图片失败 " :req.error];
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
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"分享战绩成功！"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    [alert show];

    NSLog(@"更新战绩成功");
}

- (void)upDataGamePicImageFail:(ASIHTTPRequest *)req
{
     [KKUtility showHttpErrorMsg:@"更新战绩失败 " :req.error];
}
//-------------结束战绩墙分享----------------------------------------------------------------------------------------------------

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end































