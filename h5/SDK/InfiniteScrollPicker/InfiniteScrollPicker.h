//
//  InfiniteScrollPicker.h
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InfiniteScrollPickerTouchesDelegate
-(void)scrollViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event whichView:(id)scrollView;
@end

@class InfiniteScrollPicker;

@interface InfiniteScrollPicker : UIScrollView<UIScrollViewDelegate>
{
    NSMutableArray *imageStore;
    bool snapping;
    float lastSnappingX;
}

@property(nonatomic,assign) id<InfiniteScrollPickerTouchesDelegate> touchesdelegate;

@property (nonatomic, strong) NSArray *imageAry;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) float alphaOfobjs;

@property (nonatomic) float heightOffset;
@property (nonatomic) float positionRatio;
@property (nonatomic,strong) UIImageView *biggestView;

- (void)initInfiniteScrollView;

@end
