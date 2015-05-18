//
//  Utility.h
//  ＋
//
//  Created by Administrator on 15/5/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#ifndef __Utility_h
#define __Utility_h


#endif
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CurrentUser.h"

@interface KKUtility:NSObject

+(NSDictionary*)getUserInfoFromLocalFile;

+(NSString *)intervalSinceNow: (NSString *) theDate;

#pragma clang diagnostic ignored "-Wmissing-selector-name"
+(NSString*)getUserDistinctFromMyPoint:(NSDictionary*)dStartUser:(CurrentUser *)LoginUser;

#pragma clang diagnostic ignored "-Wmissing-selector-name"
+(NSString*)calcutDistinct:(CLLocation*)kkStartPotint:(CLLocation*)kkEndPotint;

+(UIImage *)getImageFromLocal:(NSString *)imageName;

+(void)saveImageToLocal:(UIImage *)image:(NSString*)imageName;

+(NSString *)getImagePath:(NSString*)path:(NSString*)strType;
@end