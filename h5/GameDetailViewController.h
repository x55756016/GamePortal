//
//  GameDetailViewController.h
//  h5
//
//  Created by hf on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameDetailViewController : UITableViewController

@property (strong, nonatomic)NSDictionary *gameDetailDict;
@property (weak, nonatomic) IBOutlet UITableViewCell *HeadTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *contentTableViewCell;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDesLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDetailDesLabel;
@property (strong, nonatomic) UIScrollView *conScrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

- (IBAction)playGame:(id)sender;

@end
