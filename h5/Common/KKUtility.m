//
//  Utility.m
//  ＋
//
//  Created by Administrator on 15/5/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKUtility.h"
#import "CurrentUser.h"
#import "AddressBook/ABAddressBook.h"

UIKIT_EXTERN NSString *userFolderPath;

@implementation KKUtility
//获取本地文件存储的用户信息
+(NSDictionary*)getUserInfoFromLocalFile
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    
    NSDictionary *CurrentUserInfo;
    
    if (isUserInfoFolderCreate)
    {
        CurrentUserInfo = [NSDictionary dictionaryWithContentsOfFile:UserInfoFolder];
        //        NSLog(@"userInfo[%@]", userInfo);
    }
    return CurrentUserInfo;
}

//计算传入的时间戳距离当前时间戳的时差
+(NSString *)intervalSinceNow: (NSString *) theDate
{
    //
    //    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    //    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSDate *d=[date dateFromString:theDate];
    //
    NSTimeInterval oldlate=[theDate integerValue]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-oldlate;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
        
    }
    
    return timeString;
}

+(NSString*)getUserDistinctFromMyPoint:(NSDictionary*)dStartUser:(CurrentUser *)LoginUser
{
    NSString *strDistinct=[dStartUser objectForKey:@"LocJson"];
    if([strDistinct isEqual:[NSNull null]])
    {
        NSString *distinctMsg=@"未知";
        return distinctMsg;
    }
    NSArray *dicArray = [strDistinct componentsSeparatedByString:@","];
    NSString *discLongitude=[[dicArray objectAtIndex:0] substringFromIndex:1];
    NSString *discLatitude=[[dicArray objectAtIndex:1] substringToIndex:[[dicArray objectAtIndex:1] length]-1];
    CLLocation *StartPoint=[[CLLocation alloc] initWithLatitude:[discLongitude doubleValue]   longitude:[discLatitude doubleValue] ];
    //Latitude 纬度， longitude 经度
    return [self calcutDistinct:StartPoint:LoginUser.Location];
}

#pragma clang diagnostic ignored "-Wmissing-selector-name"
//计算2个经纬度之间的距离
+(NSString*)calcutDistinct:(CLLocation*)kkStartPotint:(CLLocation*)kkEndPotint
{
//    CLLocation *orig=self.UserLocation;
//    CLLocation *dist=endPotint;
    //dist.horizontalAccuracy=5;
    CLLocationDistance kilometers=[kkStartPotint distanceFromLocation:kkEndPotint];
    
    NSString *distinctMsg=@"";
    if(kilometers/1000>1)
    {
        distinctMsg=@" 相距：大于1KM";
    }
    else
    {
        
        distinctMsg=[NSString stringWithFormat:@"%@%.0f%@",@" 相距：", kilometers,@" m"];
    }
//    NSLog(@"%@",distinctMsg);
    return distinctMsg;
}

+(UIImage *)getImageFromLocal:(NSString *)imageName
{
    UIImage *image;
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"Images"]] stringByAppendingPathComponent:imageName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        image = [UIImage imageWithContentsOfFile:UserInfoFolder];
    }
    else
    {
       image=nil;
    }
    return image;
}

+(void)saveImageToLocal:(UIImage *)image:(NSString*)imageName
{
    //保存至本地
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *imageFolder = [userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"Images"]];
    NSString *imagePath = [imageFolder stringByAppendingPathComponent:imageName];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:imagePath atomically:YES];
}

+(NSString *)getImagePath:(NSString*)path:(NSString*)strType
{
    NSString *imagepath;
    if([strType isEqualToString:@"s"]){//小
    imagepath = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_s.jpg"];
    }
    if([strType isEqualToString:@"b"]){//大
        imagepath = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
    }
    if([strType isEqualToString:@"n"]){//普通
        imagepath = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_n.jpg"];
    }
    return imagepath;
}

//+ (NSMutableArray *) getAllContacts
//{
//    NSMutableArray *contactsArray = [[NSMutableArray alloc] init] ;
//    NSMutableArray* personArray = [[NSMutableArray alloc] init] ;
//    
//    ABAddressBookRef addressBook = ABAddressBookCreate();
//    NSString *firstName, *lastName, *fullName;
//    personArray = (NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
//    
//    Contacts *contact;
//    for (id *person in personArray)
//    {
//        contact = [[Contacts alloc] init];
//        firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//        firstName = [firstName stringByAppendingFormat:@" "];
//        lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
//        fullName = [firstName stringByAppendingFormat:@"%@",lastName];
//        contact.contactName = fullName;
//        
//        ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonPhoneProperty);
//        for(int i = 0 ;i < ABMultiValueGetCount(phones); i++)
//        {
//            NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
//            [contact.contactPhoneArray addObject:phone];
//        }
//        
//        ABMultiValueRef mails = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
//        for(int i = 0 ;i < ABMultiValueGetCount(mails); i++)
//        {
//            NSString *mail = (NSString *)ABMultiValueCopyValueAtIndex(mails, i);
//            [contact.contactMailArray addObject:mail];
//        }
//        [contactsArray addObject:contact];   // add contact into array
//        [contact release];
//    }
//    return contactsArray;
//}

+(void)showSystemErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error
{
    NSString *strMsg=@"系统异常。";
    if(CustomerErrorMsg!=nil)
    {
        strMsg=[strMsg stringByAppendingString:CustomerErrorMsg];
    }
    if (error!=nil) {
        strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n信息：", [error localizedDescription]];
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSLocalizedRecoveryOptionsErrorKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n错误：",[detailedError userInfo]];
            }
            
        }
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:strMsg
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    
    [alert show];
    
}

//[KKUtility showHttpErrorMsg:nil :request.error];
+(void)showHttpErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error
{
    NSString *strMsg=@"连接服务器失败，请重试或联系客服 ";
    if(CustomerErrorMsg!=nil)
    {
        strMsg=[strMsg stringByAppendingString:CustomerErrorMsg];
    }
    if (error!=nil) {
        strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n信息：", [error localizedDescription]];
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSLocalizedRecoveryOptionsErrorKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n错误：",[detailedError userInfo]];
            }
            
        }
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:strMsg
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    
    
    [alert show];

}

//保存好友信息至本地
+(void)saveFriendsToLocal:(NSArray *)FriendsArray:(NSString *)UserId
{
    @try {
        
        NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
        NSString *dataListName = @"friendList";
        NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
        

            if (![FriendsArray writeToFile:UserInfoFolder atomically:YES])
            {
                NSLog(@"保存好友信息失败");
            }
        

    }
    @catch (NSException *exception) {
        
        [self showSystemErrorMsg:exception.reason :nil];
    }
}
//从本地获取好友信息
+(NSArray*)GetFriendsFromLocal:(NSString*)UserId
{
    NSArray *friendsArray;
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = @"friendList";
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        friendsArray = [NSArray arrayWithContentsOfFile:UserInfoFolder];
    }
    return friendsArray;

}

+(void)justAlert:(NSString*)Message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Message
                                                   message:nil
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"确定", nil];
    [alert show];

}
@end