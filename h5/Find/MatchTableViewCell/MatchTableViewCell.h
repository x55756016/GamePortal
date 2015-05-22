//
//  MatchTableViewCell.h
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *matchNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchDetailLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnOpenActiveDetail;

@end
