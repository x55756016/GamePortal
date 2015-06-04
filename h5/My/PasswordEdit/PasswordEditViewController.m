//
//  ForgetPwdViewController.m
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "PasswordEditViewController.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "h5kkContants.h"
#import "KKUtility.h"

@interface PasswordEditViewController ()
{
    UITextField *currentTextField;
    ASIFormDataRequest *request;
    NSDictionary *MyInfo;
}
@end

@implementation PasswordEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setHideKeyboardGesture];
    MyInfo=[KKUtility getUserInfoFromLocalFile];
    NSString *userMobile = [NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"Mobile"]];
    [self.UserNameLabel setText:userMobile];
    
    self.oldPasswordTextField.delegate=self;
    self.pwdTextField.delegate=self;
    self.pwdAgainTextField.delegate=self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (indexPath.section==1) {
         if(indexPath.row==0)
         {
             [self nextAction];
         }
    }
   
    
}

- (void)nextAction
{
    if(([self.oldPasswordTextField.text isEqualToString:@""]) || ([self.pwdTextField.text isEqualToString:@""])
       || ([self.pwdAgainTextField.text isEqualToString:@""]))
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
                [self KKUserChangePassword];
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

-(void)KKUserChangePassword
{
    NSString *urlStr = KKUser_ChangePassword;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    
    [request setPostValue:[NSString stringWithFormat:@"%@",[MyInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [MyInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:self.oldPasswordTextField.text forKey:@"OldPassword"];
    [request setPostValue:self.pwdAgainTextField.text forKey:@"NewPassword"];

    
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
        @try {
            NSArray *result   = [dic objectForKey:@"ObjData"];
            MyInfo=[result objectAtIndex:0];
            [KKUtility  saveUserInfo:MyInfo];
        }
        @catch (NSException *exception) {
            [KKUtility logSystemErrorMsg:exception.reason :nil];
        }
        
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
    [currentTextField resignFirstResponder];
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end





















