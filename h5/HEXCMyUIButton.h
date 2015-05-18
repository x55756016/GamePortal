//
//  HEXCMyUIButton.h
//  ReAssistiveTouch
//
//  Created by clq on 13-8-12.
//  Copyright (c) 2013年 hexc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface HEXCMyUIButton : UIButton
{
    BOOL MoveEnable;
    BOOL MoveEnabled;
    CGPoint beginpoint;
}

@property(nonatomic)BOOL MoveEnable;
@property(nonatomic)BOOL MoveEnabled;

@end
