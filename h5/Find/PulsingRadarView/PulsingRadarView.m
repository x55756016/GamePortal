//
//  PulsingRadarView.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "PulsingRadarView.h"

@implementation PulsingRadarView

- (void)drawRect:(CGRect)rect
{
    self.animationLayer = [CALayer layer];
    for (int i = 0; i < 8; i++)
    {
        CALayer *pulsingLayer = [CALayer layer];
        pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        pulsingLayer.borderColor = [[UIColor whiteColor] CGColor];
        pulsingLayer.borderWidth = 1;
        pulsingLayer.cornerRadius = rect.size.height / 2;
        
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + i * 6 / 8;
        animationGroup.duration = 6;
        animationGroup.repeatCount = HUGE_VAL;
        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.autoreverses = false;
        scaleAnimation.fromValue = @0;
        scaleAnimation.toValue = @1.5;
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@1, @0.7, @0];
        opacityAnimation.keyTimes = @[@0, @0.5, @1];
        
        animationGroup.animations = @[scaleAnimation,opacityAnimation];
        [pulsingLayer addAnimation:animationGroup forKey:@"pulsing"];
        [self.animationLayer addSublayer:pulsingLayer];
    }
    
    [self.layer addSublayer:self.animationLayer];
}

@end























