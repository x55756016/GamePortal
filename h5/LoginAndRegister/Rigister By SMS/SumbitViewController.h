//
//  SumbitViewController.h
//  h5
//
//  Created by hf on 15/4/1.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SumbitViewController : UITableViewController <UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic)NSString *phoneStr;
@property (strong, nonatomic)NSString *codeStr;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgainTextField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *inputScrollView;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
- (IBAction)nextAction:(id)sender;

@end
