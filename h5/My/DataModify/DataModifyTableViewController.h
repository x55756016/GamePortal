//
//  DataModifyTableViewController.h
//  h5
//
//  Created by wwj on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MeDetailNameTableViewController.h"
#import "MeDetailAgeTableViewController.h"
#import "MeDetailSexTableViewController.h"
#import "MeDetailLocalTableViewController.h"
#import "SignatureTableViewController.h"

@interface DataModifyTableViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,MeDetailNameTableViewControllerDelegate, MeDetailSexTableViewControllerDelegate, MeDetailAgeTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *headPathCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *idCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *rankCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *nickNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sexCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *signatureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *loveCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *saveCell;

@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
- (IBAction)selectHeadImageTapGesAction:(id)sender;

@end
