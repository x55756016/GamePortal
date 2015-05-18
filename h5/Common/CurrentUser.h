//
//  CurrentUser.h
//  ＋
//
//  Created by Administrator on 15/5/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#ifndef __CurrentUser_h
#define __CurrentUser_h


#endif
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CurrentUser:NSObject

@property (strong, nonatomic)NSString *UserName;
@property (strong, nonatomic)NSString *UserId;
@property (strong, nonatomic)NSString *UserHeadUrl;

//"\(currentLocation.coordinate.latitude)"
//"\(currentLocation.coordinate.longitude)"
@property (strong, nonatomic)NSString *Longitude;//经度
@property (strong, nonatomic)NSString *Latitude;//纬度
@property (strong, nonatomic) CLLocation *Location;


@property (strong, nonatomic) NSDictionary *userSaveInfo;


@end
