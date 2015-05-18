//
//  MeDetailLocalTableViewController.h
//  ooz
//
//  Created by wwj on 14-5-11.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeDetailLocalTableViewController : UITableViewController

@property(strong, nonatomic)NSArray *Provinces;
@property(strong, nonatomic)NSArray *Cities;
@property(strong, nonatomic)NSString *State;
@property(strong, nonatomic)NSDictionary *userInfo;

@end
