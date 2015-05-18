//
//  MeDetailSexTableViewController.h
//  ooz
//
//  Created by wwj on 14-5-8.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MeDetailSexTableViewController;
@protocol MeDetailSexTableViewControllerDelegate
-(void)meDetailSexTableViewControllerSave:(MeDetailSexTableViewController *)meDetailSexTableViewController;
@end

@interface MeDetailSexTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *manTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *womanTableViewCell;

@property (weak, nonatomic)id <MeDetailSexTableViewControllerDelegate> MDSTVCdelegate;
@property (strong, nonatomic)NSString *sexSegueString;


@end
