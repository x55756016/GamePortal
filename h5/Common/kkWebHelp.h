//
//  kkWebHelp.h
//  ＋
//
//  Created by Administrator on 15/5/18.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol addGameConfigCompleteDelegate<NSObject>

- (void)addGameConfigComplete:(NSString *)value;

@end

@interface kkWebHelp : NSObject 

#pragma clang diagnostic ignored "-Wmissing-selector-name"
-(void)addMyGameToServer:(NSDictionary *)addGameDict:(NSDictionary*)userInfo;

@property(nonatomic, retain) id<addGameConfigCompleteDelegate> delegate;

@end
