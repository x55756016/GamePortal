//
//  LoginViewController.m
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "MyNavigationController.h"
#import "h5kkContants.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface LoginViewController ()
{
    AppDelegate *appDelegate;
    UITextField *currentTextField;
    NSDictionary *userInfo;
    unsigned long accountTextFieldlength;  //账号长度
    unsigned long passwordTextFieldlength; //密码长度
    
    ASIFormDataRequest *request;
}
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self setHideKeyboardGesture];

    self.headImageView.frame = CGRectMake(self.headImageView.frame.origin.x, self.headImageView.frame.origin.y, 100, 100);
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = CGRectGetHeight([self.headImageView bounds])/2;
    self.headImageView.layer.borderWidth = 2;
    self.headImageView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    
    self.loginButton.alpha = 0.6;
    self.inputScrollView.contentSize = CGSizeMake(320, 417);
//    NSLog(@"[%f][%f]", self.inputScrollView.contentOffset.x, self.inputScrollView.contentOffset.y);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self showUserInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
    {
        [self doLogin];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络后重试"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)forgetPwd:(id)sender
{
    [self performSegueWithIdentifier:@"PushForgetPwd" sender:nil];
}

- (IBAction)doRegister:(id)sender
{
    [self performSegueWithIdentifier:@"PushReg" sender:nil];
}

-(void)doLogin
{
    NSString *urlStr = LOGIN;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:self.accountTextField.text forKey:@"UserName"];
    [request setPostValue:self.passwordTextField.text forKey:@"Password"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"%@", dic);
    
    [SVProgressHUD dismiss];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        //保存个人信息至本地
        [self saveUserInfo:dic];
        
        //登录融云服务器获取Token
        [self connectToRCServer];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarController *myc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        [self presentViewController:myc animated:NO completion:nil];
    }
    else
    {
        NSString *msgStr = [dic objectForKey:@"Msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                        message:msgStr
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                    message:@"请检查网络后重试"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//--------------------------------登录成功保存用户信息至本地---------------------------------------//
-(void)saveUserInfo:(NSDictionary *)dic
{
    NSArray *userInfoArr = [dic objectForKey:@"ObjData"];
    NSDictionary *userInfoDir =(NSDictionary *)userInfoArr[0];
//    NSLog(@"%@", userInfoDir);
    
    NSString *userIdFolder = [self createFolder:[NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"UserId"]]];
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSString *UserInfoFolder = [userIdFolder stringByAppendingPathComponent:@"UserInfo.plist"];
    
    BOOL isUserInfoFolderCreate = [appFileManager fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (!isUserInfoFolderCreate)
    {
        NSMutableDictionary *userInfoDicy = [[NSMutableDictionary alloc] init];
        if (![userInfoDicy writeToFile:UserInfoFolder atomically:YES])
        {
            NSLog(@"创建用户个人信息文件失败");
        }
    }
    
    NSString *filePath = [userIdFolder stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![userInfoDir writeToFile:filePath atomically:YES])
    {
        NSLog(@"保存用户信息失败");
    }
    
    //标记已登录
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    [saveDefaults setObject:@"YES" forKey:@"isLogin"];
    
    //标记当前登记的账号
    [saveDefaults setObject:[NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"UserId"]] forKey:@"currentId"];
    
    //UI上的登记账号
    [saveDefaults setObject:self.accountTextField.text forKey:@"account"];
    
    //保存头像
    UserInfoFolder = [userIdFolder stringByAppendingPathComponent:@"icon.jpg"];
    isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (!isUserInfoFolderCreate)
    {
        NSString *HeadIMGstring = [NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"PicPath"]];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        NSURL *url = [NSURL URLWithString:HeadIMGstring];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        [imageData writeToFile:UserInfoFolder atomically:YES];
        [saveDefaults setObject:imageData forKey:@"headImg"];
    }
}

//本地用户信息
-(void)showUserInfo
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    if ([saveDefaults objectForKey:@"account"])
    {
        self.accountTextField.text = [saveDefaults objectForKey:@"account"];
        accountTextFieldlength = [self.accountTextField.text length];
    }
    
    if ([saveDefaults objectForKey:@"headImg"])
    {
        self.headImageView.image = [UIImage imageWithData:[saveDefaults dataForKey:@"headImg"]];
    }
}

//-----------------------------------登录融云服务器获取Token----------------------------------------//
-(void)connectToRCServer
{
    //本地获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    NSLog(@"[LoginViewController]MsgToken[%@]", [userInfo objectForKey:@"MsgToken"]);
    
    //连接融云服务器
    [RCIM connectWithToken:[userInfo objectForKey:@"MsgToken"] completion:^(NSString *userId) {
        NSLog(@"[LoginViewController]Login successfully with userId: %@.", userId);
    } error:^(RCConnectErrorCode status) {
        NSLog(@"[LoginViewController]Login failed.");
    }];
}

//用UserId给每个用户创建本地文件夹
- (NSString *)createFolder:(NSString *)folderNameStr
{
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSString *userFolderPathTemp = [userFolderPath stringByAppendingPathComponent:folderNameStr];

    BOOL isUserFolderCreate = [appFileManager fileExistsAtPath:userFolderPathTemp isDirectory:nil];
    if (!isUserFolderCreate)
    {
        if (![appFileManager createDirectoryAtPath:userFolderPathTemp withIntermediateDirectories:YES attributes:nil error:nil])
        {
            NSLog(@"用户的文件创建失败");
        }
        else
        {
            return userFolderPathTemp;
        }
    }
    return nil;
}

//---------------------------------点击空白处隐藏键盘-----------------------------------------------//
-(void)setHideKeyboardGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)HideKeyboard:(UITapGestureRecognizer *)tap
{
    [self.inputScrollView setContentOffset:CGPointMake(0, -20) animated:YES];
    [currentTextField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //获取键盘y
    NSDictionary *userInfoTemp = [notif userInfo];
    NSValue *aValue = [userInfoTemp objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.size.height;
    float keyboardY = [UIScreen mainScreen].bounds.size.height - keyboardHeight;
//    NSLog(@"keyboardY[%f]", keyboardY);
    
    //"下一步"按钮的底部y
    float nextButtonBottomY = self.loginButton.frame.origin.y + self.loginButton.frame.size.height;
//    NSLog(@"nextButtonBottomY[%f]", nextButtonBottomY);
    
    if(currentTextField == self.passwordTextField)
    {
        if(nextButtonBottomY > keyboardY)
        {
            [self.inputScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
            self.inputScrollView.scrollEnabled = NO;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    self.inputScrollView.scrollEnabled = YES;
}

//------------------------------------UITextFieldDelegate---------------------------------------------------------//
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.accountTextField)
    {
        accountTextFieldlength = toBeString.length;
    }
    
    if (textField == self.passwordTextField)
    {
        passwordTextFieldlength = toBeString.length;
    }
    
    if ((accountTextFieldlength != 0) && (passwordTextFieldlength != 0))
    {
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0;
    }
    else
    {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.6;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.accountTextField)
    {
        accountTextFieldlength = 0;
    }
    
    if (textField == self.passwordTextField)
    {
        passwordTextFieldlength = 0;
    }
    
    self.loginButton.enabled = NO;
    self.loginButton.alpha = 0.6;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = textField;
    
    //因为在故事板里设置了Clear When Editing Begins
    if (textField == self.passwordTextField)
    {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.6;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.accountTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    
    if (textField == self.passwordTextField)
    {
        [textField resignFirstResponder];
        [self login:nil];
    }
    
    return YES;
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end






















