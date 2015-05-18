//
//  MatchTableViewCell.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "MatchTableViewCell.h"

@implementation MatchTableViewCell

- (void)awakeFromNib
{
    self.matchDetailLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
