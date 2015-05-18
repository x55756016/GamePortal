//
//  MeDetailCitiesTableViewController.h
//  ooz
//
//  Created by wwj on 14-5-12.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeDetailCitiesTableViewController : UITableViewController

@property(strong, nonatomic)NSArray *CitiesSegueArry;
@property(strong, nonatomic)NSString *StateSegue;
@property(strong, nonatomic)NSDictionary *userInfo;

@end
