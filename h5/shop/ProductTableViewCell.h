//
//  ProductTableViewCell.h
//  ＋
//
//  Created by Administrator on 15/5/28.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *ProductImage;
@property (strong, nonatomic) IBOutlet UILabel *ProductName;

@property (strong, nonatomic) IBOutlet UILabel *ProductDescription;
@property (strong, nonatomic) IBOutlet UIButton *ProductBuyButton;
@end
