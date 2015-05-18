//
//  GameViewController.h
//  h5
//
//  Created by hf on 15/3/30.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameListViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *hotGameBtn;
@property (strong, nonatomic) IBOutlet UIButton *myGameBtn;
@property (strong, nonatomic) IBOutlet UIButton *ClassifyBtn;
@property (strong, nonatomic) IBOutlet UIView *shadowView;
- (IBAction)selectNameButton:(id)sender;
@property (strong, nonatomic) UIScrollView *conScrollView;

@property (strong, nonatomic) IBOutlet UITableView *hotGameTableView;
@property (strong, nonatomic) IBOutlet UITableView *myGameTableView;
@property (strong, nonatomic) IBOutlet UITableView *classifyTableView;

@end
