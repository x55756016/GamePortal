//
//  SignatureTableViewController.m
//  ParkingLot
//
//  Created by wwj on 14/12/21.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import "SignatureTableViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface SignatureTableViewController ()
@end

@implementation SignatureTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.signatureTextView becomeFirstResponder];
    self.signatureTextView.text = self.signatureSegueString;
    NSUInteger maxLength = 30;
    self.signatureMaxLabel.text = [NSString stringWithFormat:@"%u", (UInt16)(maxLength-self.signatureTextView.text.length)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self saveUserInfo];
    [super viewWillDisappear:animated];
}

//-------------------------------tableView-----------------------------------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0)
    {
        cell = self.SignatureCell;
    }
    
    return cell;
}

//-------------------------------UITextViewDelegate----------------------------------------//
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self saveUserInfo];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.signatureTextView)
    {
        if (textView.text.length > 30)
        {
            textView.text = [textView.text substringToIndex:30];
        }
        else
        {
            NSUInteger maxLength = 30;
            self.signatureMaxLabel.text = [[NSString stringWithFormat:@"%u", (UInt16)(maxLength-self.signatureTextView.text.length)] stringByAppendingString:@"/30"];
        }
    }
}

-(void)saveUserInfo
{
    [self.userInfo setValue:self.signatureTextView.text forKey:@"Sign"];
    
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![self.userInfo writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存用户信息失败");
    }
}

@end






















