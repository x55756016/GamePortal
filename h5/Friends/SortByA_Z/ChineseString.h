//
//  ChineseString.h
//  YZX_ChineseSorting
//
//  Created by Suilongkeji on 13-10-29.
//  Copyright (c) 2013年 Suilongkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pinyin.h"

@interface ChineseString : NSObject
@property(retain,nonatomic)NSString *string;
@property(retain,nonatomic)NSString *pinYin;
@property(retain,nonatomic)NSDictionary *userInfoDict;

//按首字母排序以及分类
+(NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort sectionHeadsKeys:(NSMutableArray *)sectionHeadsKeys;

@end