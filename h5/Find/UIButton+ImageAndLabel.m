//
//  UIButton+ImageAndLabel.m
//  ＋
//
//  Created by Administrator on 15/5/9.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "UIButton+ImageAndLabel.h"

@implementation UIButton (ImageAndLabel)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    UIFont *font = [UIFont fontWithName:@"Arial" size:10.0f];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:10]};

    CGSize titleSize = [title sizeWithAttributes:attributes];
    [self.imageView setContentMode:UIViewContentModeScaleToFill];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-8.0,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:font];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(30.0,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}
@end
