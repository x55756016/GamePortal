//
//  ChatListViewController.h
//  h5
//
//  Created by hf on 15/4/10.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCIM.h"
#import "RCChatListViewController.h"

@interface ChatListViewController : RCChatListViewController <RCIMUserInfoFetcherDelegagte, RCIMFriendsFetcherDelegate, RCIMReceiveMessageDelegate, RCIMConnectionStatusDelegate>

@property (strong, nonatomic) NSMutableArray *allFriendsArray;
- (IBAction)ShowCustomServicer:(id)sender;

@end
