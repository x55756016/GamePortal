//
//  RegisterViewController.h
//  h5
//
//  Created by hf on 15/3/31.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionsViewController.h"

@interface RegisterViewController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,SecondViewControllerDelegate,UITextFieldDelegate>

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) UITextField* areaCodeField;
@property(nonatomic,strong) UITextField* telField;
@property(nonatomic,strong) UIWindow* window;
@property(nonatomic,strong) UIButton* next;
-(void)nextStep;

@end
