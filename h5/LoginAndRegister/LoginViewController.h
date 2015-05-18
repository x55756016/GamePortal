//
//  LoginViewController.h
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainTabBarController.h"
#import "AppDelegate.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *inputScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)login:(id)sender;
- (IBAction)forgetPwd:(id)sender;
- (IBAction)doRegister:(id)sender;

@end
