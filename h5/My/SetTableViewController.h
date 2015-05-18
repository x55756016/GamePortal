//
//  SetTableViewController.h
//  h5
//
//  Created by hf on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCIM.h"

@interface SetTableViewController : UITableViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *imageCachePathCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *imageLoadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *alertCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cleanCacheCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *upgradeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *feedbackCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *scoreCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aboutCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *exitCell;

@end
