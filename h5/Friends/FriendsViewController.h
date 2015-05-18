//
//  FriendsViewController.h
//  h5
//
//  Created by wwj on 15/4/5.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *friendTableView;
@property (nonatomic, retain) NSMutableArray *dataArr;
@property (nonatomic, retain) NSMutableArray *sortedArrForArrays;
@property (nonatomic, retain) NSMutableArray *sectionHeadsKeys;

@end
