//
//  MyTableViewController.h
//  h5
//
//  Created by hf on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *selectHeadImageTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *accountTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *vipTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *settingTableViewCell;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end
