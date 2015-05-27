//
//  SquareTableViewController.h
//  h5
//
//  Created by hf on 15/4/16.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SquareTableViewController : UITableViewController

@property NSInteger timepageIndex;

@property (strong, nonatomic) IBOutlet UIScrollView *adScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)imagePressed:(id)sender;

@end
