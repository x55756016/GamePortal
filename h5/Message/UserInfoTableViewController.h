//
//  UserInfoTableViewController.h
//  h5
//
//  Created by wwj on 15/4/6.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCIM.h"
#import "InfiniteScrollPicker.h"

@interface UserInfoTableViewController : UITableViewController<InfiniteScrollPickerTouchesDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *HeadTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *accountTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *distanceTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *signTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *contentTableViewCell;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (strong, nonatomic)NSDictionary *FriendInfoDict;
@property (weak, nonatomic) IBOutlet UIButton *AddFriendButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *GameListCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *HistoryListCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *OpertationCell;
@property (weak, nonatomic) IBOutlet UIView *FriendGameListView;
@property (weak, nonatomic) IBOutlet UIView *FriendHistoryListView;
- (IBAction)singleChat:(id)sender;

- (IBAction)AddFriend:(id)sender;

@end
