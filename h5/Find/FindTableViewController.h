//
//  FindTableViewController.h
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPresentAnimation.h"
#import "RadarViewController.h"

@interface FindTableViewController : UITableViewController <UIViewControllerTransitioningDelegate, RadarViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *kkTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *aroundTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *squareTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *matchTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *kkBarTableViewCell;

@property (nonatomic, strong) CustomPresentAnimation *customPresentAnimation;

@end
