//
//  SumbitViewController.m
//  h5
//
//  Created by hf on 15/4/1.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SumbitViewController.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "h5kkContants.h"
#import "AppDelegate.h"

@interface SumbitViewController ()
{
    UITextField *currentTextField;
    
    ASIFormDataRequest *request;
}
@end

@implementation SumbitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.phoneTextField.text = self.phoneStr;
    self.verificationCodeTextField.text = self.codeStr;
    
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

- (IBAction)nextAction:(id)sender
{
    if(([self.phoneTextField.text isEqualToString:@""]) || ([self.verificationCodeTextField.text isEqualToString:@""])
       || ([self.pwdTextField.text isEqualToString:@""]) || ([self.pwdAgainTextField.text isEqualToString:@""]) || ([self.nickNameTextField.text isEqualToString:@""]))
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
                [self sumbitRegister];
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

-(void)sumbitRegister
{
    NSString *urlStr = REGISTER;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:self.phoneTextField.text forKey:@"UserName"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:self.pwdTextField.text forKey:@"Password"];
    [request setPostValue:self.phoneTextField.text forKey:@"Mobile"];
    [request setPostValue:self.nickNameTextField.text forKey:@"NickName"];
    
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strlon=kkAppDelegate.currentlogingUser.Longitude;//经度
    NSString *strlat=kkAppDelegate.currentlogingUser.Latitude;//纬度
    
    [request setPostValue:strlon forKey:@"lon"];
    [request setPostValue:strlat forKey:@"lat"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"dic[%@]", dic);
    
    [SVProgressHUD dismiss];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册成功"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *msgStr = [dic objectForKey:@"Msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册失败"
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册失败"
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
    
    if((currentTextField == self.pwdAgainTextField) || (currentTextField == self.nickNameTextField))
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
- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end



































