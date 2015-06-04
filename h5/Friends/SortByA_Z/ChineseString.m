//
//  ChineseString.m
//  YZX_ChineseSorting
//
//  Created by Suilongkeji on 13-10-29.
//  Copyright (c) 2013年 Suilongkeji. All rights reserved.
//

#import "ChineseString.h"

@implementation ChineseString
@synthesize string;
@synthesize pinYin;
@synthesize userInfoDict;

//按首字母排序以及分类
+(NSMutableArray *)getChineseStringArr:(NSMutableArray *)arrToSort sectionHeadsKeys:(NSMutableArray *)sectionHeadsKeys
{
    NSMutableArray *chineseStringsArray = [NSMutableArray array];
    for(int i = 0; i < [arrToSort count]; i++)
    {
        ChineseString *chineseString = [[ChineseString alloc]init];
        NSDictionary *userInfoDict = [arrToSort objectAtIndex:i];
        chineseString.string = [NSString stringWithFormat:@"%@", [userInfoDict objectForKey:@"NickName"]];
        
        if(chineseString.string == nil)
        {
            chineseString.string = @"";
        }
        
        if(![chineseString.string isEqualToString:@""])
        {
            NSString *pinYinResult = [NSString string];
            for(int j = 0; j < chineseString.string.length; j++)
            {
                NSString *singlePinyinLetter;
                unichar singleChar = [chineseString.string characterAtIndex:j];
                
                if((singleChar >= 'A' && singleChar <= 'Z') || (singleChar >= 'a' && singleChar <= 'z'))
                {
                    singlePinyinLetter = [[NSString stringWithFormat:@"%c", singleChar]uppercaseString];
                }
                else
                {
                    singlePinyinLetter = [[NSString stringWithFormat:@"%c", pinyinFirstLetter(singleChar)]uppercaseString];
                }
                pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin = pinYinResult;
        }
        else
        {
            chineseString.pinYin = @"";
        }
        
        chineseString.userInfoDict = userInfoDict;
        [chineseStringsArray addObject:chineseString];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    //获取sectionHeadsKeys
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;
    NSMutableArray *TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        ChineseString *chineseStr = (ChineseString *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:chineseStr.pinYin];
        NSString *sr= [strchar substringToIndex:1];
        
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return arrayForArrays;
}

@end











































