//
//  MeDetailNameTableViewController.h
//  ooz
//
//  Created by wwj on 14-5-6.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeDetailNameTableViewController;
@protocol MeDetailNameTableViewControllerDelegate
-(void)meDetailNameTableViewControllerCancle:(MeDetailNameTableViewController *)meDetailNameTableViewController;
-(void)meDetailNameTableViewControllerSave:(MeDetailNameTableViewController *)meDetailNameTableViewController;
@end

@interface MeDetailNameTableViewController : UITableViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *nameTableViewCell;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic)id <MeDetailNameTableViewControllerDelegate> MDNTVCdelegate;
- (IBAction)doCancle:(id)sender;
- (IBAction)doSave:(id)sender;

@property (strong, nonatomic)NSString *nameSegueString;

@end
