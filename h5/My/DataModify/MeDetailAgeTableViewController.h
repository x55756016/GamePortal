//
//  MeDetailAgeTableViewController.h
//  h5
//
//  Created by hf on 15/4/3.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeDetailAgeTableViewController;
@protocol MeDetailAgeTableViewControllerDelegate
-(void)meDetailAgeTableViewControllerCancle:(MeDetailAgeTableViewController *)meDetailAgeTableViewController;
-(void)meDetailAgeTableViewControllerSave:(MeDetailAgeTableViewController *)meDetailAgeTableViewController;
@end

@interface MeDetailAgeTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *ageTableViewCell;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@property (weak, nonatomic)id <MeDetailAgeTableViewControllerDelegate> MDATVCdelegate;

- (IBAction)doCancle:(id)sender;
- (IBAction)doSave:(id)sender;

@property (strong, nonatomic)NSString *ageSegueString;

@end
