//
//  RadarViewController.h
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulsingRadarView.h"

@class RadarViewController;
@protocol RadarViewControllerDelegate <NSObject>
-(void) radarViewControllerDidClickedDismissButton:(RadarViewController *)viewController;
@end

@interface RadarViewController : UIViewController
@property (nonatomic, weak) id<RadarViewControllerDelegate> RVCdelegate;
//雷达脉冲
@property (nonatomic, strong) PulsingRadarView *pulsingRadarView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *AllUsers;

- (IBAction)ShowUserInfo:(id)sender;

- (IBAction)showAllFriendInfo:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *backView;

@end
