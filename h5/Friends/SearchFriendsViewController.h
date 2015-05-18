//
//  SearchFriendsViewController.h
//  h5
//
//  Created by wwj on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@end
