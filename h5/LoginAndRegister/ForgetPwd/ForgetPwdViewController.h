//
//  ForgetPwdViewController.h
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPwdViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgainTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *inputScrollView;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)nextAction:(id)sender;

- (IBAction)getVerificationCode:(id)sender;

@end
