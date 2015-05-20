//
//  ForgetPwdViewController.m
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "h5kkContants.h"

@interface ForgetPwdViewController ()
{
    UITextField *currentTextField;
    ASIFormDataRequest *request;
}
@end

@implementation ForgetPwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setHideKeyboardGesture];
    self.inputScrollView.contentSize = CGSizeMake(320, 417);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)getVerificationCode:(id)sender
{
    if (self.phoneTextField.text.length != 11)
    {
        //手机号码不正确
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                      message:NSLocalizedString(@"errorphonenumber", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                            otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"willsendthecodeto", nil),self.phoneTextField.text];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil)
                                                      message:str delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                            otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
        [alert show];
    }
}

- (IBAction)nextAction:(id)sender
{
    if(([self.phoneTextField.text isEqualToString:@""]) || ([self.verificationCodeTextField.text isEqualToString:@""])
       || ([self.pwdTextField.text isEqualToString:@""]) || ([self.pwdAgainTextField.text isEqualToString:@""]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"内容不能为空"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        if(![self.pwdTextField.text isEqualToString:self.pwdAgainTextField.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码输入不一致,请重新输入"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
            {
                [self findPwd];
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
    }
}

-(void)findPwd
{
    NSString *urlStr = FIND_PWD;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:self.phoneTextField.text forKey:@"PhoneNumber"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:@"86" forKey:@"Zode"];
    [request setPostValue:self.verificationCodeTextField.text forKey:@"Code"];
    [request setPostValue:self.pwdTextField.text forKey:@"Password"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"dic[%@]", dic);
    
    [SVProgressHUD dismiss];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改成功"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *msgStr = [dic objectForKey:@"Msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败"
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败"
                                                    message:@"请检查网络后重试"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//点击空白处隐藏键盘
-(void)setHideKeyboardGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)HideKeyboard:(UITapGestureRecognizer *)tap
{
    [self.inputScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [currentTextField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //获取键盘y
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyboardHeight = keyboardRect.size.height;
    float keyboardY = [UIScreen mainScreen].bounds.size.height - keyboardHeight;
//    NSLog(@"keyboardY[%f]", keyboardY);
    
    //"下一步"按钮的底部y
    float nextButtonBottomY = self.nextButton.frame.origin.y + self.nextButton.frame.size.height;
//    NSLog(@"nextButtonBottomY[%f]", nextButtonBottomY);
    
    if(currentTextField == self.pwdAgainTextField)
    {
        if(nextButtonBottomY > keyboardY)
        {
            [self.inputScrollView setContentOffset:CGPointMake(0, 150) animated:YES];
            self.inputScrollView.scrollEnabled = NO;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    self.inputScrollView.scrollEnabled = YES;
}

//--------------------------UITextFieldDelegate--------------------------//
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = textField;
}

//--------------------------------------------UIAlertViewDelegate----------------------------------------------------//
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1==buttonIndex)
    {
        [SMS_SDK getVerificationCodeBySMSWithPhone:self.phoneTextField.text zone:@"86" result:^(SMS_SDKError *error)
        {
            if (error)
            {
                 UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                                               message:[NSString stringWithFormat:@"状态码：%zi ,错误描述：%@",error.errorCode,error.errorDescription]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                     otherButtonTitles:nil, nil];
                 [alert show];
            }
        }];
    }
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end





















