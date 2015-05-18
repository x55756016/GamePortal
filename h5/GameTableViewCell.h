//
//  GameTableViewCell.h
//  h5
//
//  Created by wwj on 15/4/5.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDesLabel;
@property (strong, nonatomic) IBOutlet UIButton *playGameBtn;

@end
