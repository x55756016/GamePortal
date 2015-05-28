//
//  InAppRageIAPHelper.m
//  ＋
//
//  Created by Administrator on 15/5/27.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "InAppRageIAPHelper.h"

@implementation InAppRageIAPHelper

static InAppRageIAPHelper * _sharedHelper;

+ (InAppRageIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[InAppRageIAPHelper alloc] init];
    return _sharedHelper;
    
}

- (id)init {
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.shenyang.h5.KKcoin",
                                 @"com.shenyang.h5.member",
                                 nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }
    return self;
    
}

@end
