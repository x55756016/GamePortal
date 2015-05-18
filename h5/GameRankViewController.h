//
//  GameRankViewController.h
//  h5
//
//  Created by hf on 15/4/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameRankViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *gameDetailDict;
@property (strong, nonatomic) IBOutlet UIButton *worldRankBtn;
@property (strong, nonatomic) IBOutlet UIButton *chinaRankBtn;
@property (strong, nonatomic) IBOutlet UIButton *cityRankBtn;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
- (IBAction)selectNameButton:(id)sender;
@property (strong, nonatomic) UIScrollView *conScrollView;

@property (strong, nonatomic) IBOutlet UITableView *worldRankTableView;
@property (strong, nonatomic) IBOutlet UITableView *chinaRankTableView;
@property (strong, nonatomic) IBOutlet UITableView *cityRankTableView;

@end
