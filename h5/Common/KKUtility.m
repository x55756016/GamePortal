//
//  Utility.m
//  ＋
//
//  Created by ken on 15/5/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKUtility.h"
#import "CurrentUser.h"
#import "AddressBook/ABAddressBook.h"
#import "h5kkContants.h"
#import "AppDelegate.h"

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

+(BOOL)StringIsEmptyOrNull:(NSString*)kenString
{
    if (kenString == nil || kenString == NULL) {
        return YES;
    }
    if ([kenString isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[kenString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    if([kenString isEqual:[NSNull null]])
    {
        return YES;
    }
    return NO;
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
    CLLocationDistance kilometers=[kkStartPotint distanceFromLocation:kkEndPotint];
    
    NSString *distinctMsg=@"";
    if(kilometers/1000<10000)
    {
        distinctMsg=@"10公里以内";
    }
    if(kilometers/1000<=9000)
    {
        distinctMsg=@"9公里以内";
    }
    if(kilometers/1000<=8000)
    {
        distinctMsg=@"8公里以内";
    }
    if(kilometers/1000<=7000)
    {
        distinctMsg=@"7公里以内";
    }
    if(kilometers/1000<=6000)
    {
        distinctMsg=@"6公里以内";
    }
    if(kilometers/1000<=5000)
    {
        distinctMsg=@"5公里以内";
    }
    if(kilometers/1000<=4000)
    {
        distinctMsg=@"4公里以内";
    }
    if(kilometers/1000<=3000)
    {
        distinctMsg=@"3公里以内";
    }
    if(kilometers/1000<=2000)
    {
        distinctMsg=@"2公里以内";
    }
    if(kilometers/1000<=1000)
    {
        distinctMsg=@"1公里以内";
    }
    if(kilometers/1000<=900)
    {
        distinctMsg=@"900米以内";
    }
    if(kilometers/1000<=800)
    {
        distinctMsg=@"800米以内";
    }
    if(kilometers/1000<=700)
    {
        distinctMsg=@"700米以内";
    }
    if(kilometers/1000<=600)
    {
        distinctMsg=@"600米以内";
    }
    if(kilometers/1000<=500)
    {
        distinctMsg=@"500米以内";
    }
    if(kilometers/1000<=400)
    {
        distinctMsg=@"400米以内";
    }
    if(kilometers/1000<=300)
    {
        distinctMsg=@"300米以内";
    }
    if(kilometers/1000<=200)
    {
        distinctMsg=@"200米以内";
    }
    if(kilometers/1000<=100)
    {
        distinctMsg=@"100米以内";
    }
    
//    if(kilometers/1000>1)
//    {
//        distinctMsg=@" 距离:大于1公里";
//    }
//    else
//    {
//        distinctMsg=[NSString stringWithFormat:@"%@%.0f%@",@" 距离:", kilometers,@" m"];
//    }
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

+(NSString *)getKKImagePath:(NSString*)path:(NSString*)strType
{
    if([strType isEqualToString:@"s"]){//小
        NSString *existStr = @"_s.jpg";
        if ([path rangeOfString:existStr].location == NSNotFound){
            path = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_s.jpg"];
            path = [path stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_s.jpeg"];
            path = [path stringByReplacingOccurrencesOfString:@".png" withString:@"_s.png"];
        }
    }
    if([strType isEqualToString:@"b"]){//大
        NSString *existStr = @"_b.jpg";
        if ([path rangeOfString:existStr].location == NSNotFound){
            path = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
            path = [path stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_b.jpeg"];
            path = [path stringByReplacingOccurrencesOfString:@".png" withString:@"_b.png"];
        }
    }
    if([strType isEqualToString:@"n"]){//普通
        NSString *existStr = @"_n.jpg";
        if ([path rangeOfString:existStr].location == NSNotFound){
            path = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"_n.jpg"];
            path = [path stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_n.jpeg"];
            path = [path stringByReplacingOccurrencesOfString:@".png" withString:@"_n.png"];
        }
    }
    return path;
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
+(void)logSystemErrorMsg:(NSString*)CustomerErrorMsg:(NSError*)error
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
    
    //保存至本地
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *kklogsFolder = [userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"kklogs"]];
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMdd"];
    NSString *  currentDate=[dateformatter stringFromDate:senddate];
    NSString *logsPath = [kklogsFolder stringByAppendingPathComponent:currentDate];
    NSData *logData = [strMsg dataUsingEncoding:NSUTF8StringEncoding];
    [logData writeToFile:logsPath atomically:YES];
    
}


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
    strMsg=@"连接服务器失败,请检查网络情况";
//    if(CustomerErrorMsg!=nil)
//    {
//        strMsg=[strMsg stringByAppendingString:CustomerErrorMsg];
//    }
//    if (error!=nil) {
//        strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n信息：", [error localizedDescription]];
//        NSArray* detailedErrors = [[error userInfo] objectForKey:NSLocalizedRecoveryOptionsErrorKey];
//        if(detailedErrors != nil && [detailedErrors count] > 0) {
//            for(NSError* detailedError in detailedErrors) {
//                strMsg=[strMsg stringByAppendingFormat:@"%@,%@",@" \n错误：",[detailedError userInfo]];
//            }
//            
//        }
//        
//    }
    
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


//--------------------------------登录成功保存用户信息至本地---------------------------------------//
+(void)saveUserInfo:(NSDictionary *)userInfoDir
{
    //    NSLog(@"%@", userInfoDir);
    
    NSString *userIdFolder = [self createFolder:[NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"UserId"]]];
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSString *UserInfoFilePath = [userIdFolder stringByAppendingPathComponent:@"UserInfo.plist"];
    
    BOOL isFileCreate = [appFileManager fileExistsAtPath:UserInfoFilePath isDirectory:nil];
    //如果文件不存在，创建
    if (!isFileCreate)
    {
        NSMutableDictionary *userInfoDicy = [[NSMutableDictionary alloc] init];
        if ([userInfoDicy writeToFile:UserInfoFilePath atomically:YES])
        {
            NSLog(@"创建用户个人信息文件成功。");
        }else
        {
            NSLog(@"创建用户个人信息文件失败！");

        }
    }else
    {
        if ([userInfoDir writeToFile:UserInfoFilePath atomically:YES])
        {
            NSLog(@"覆盖用户信息本地文件成功。");
        }else
        {
              NSLog(@"覆盖用户信息本地文件失败！");
        }
    }

    
    //标记已登录
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    [saveDefaults setObject:@"YES" forKey:@"isLogin"];
    
    //标记当前登记的账号
    [saveDefaults setObject:[NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"UserId"]] forKey:@"currentId"];
    
    //UI上的登记账号
    [saveDefaults setObject:[userInfoDir objectForKey:@"Mobile"] forKey:@"account"];
    
//    //保存头像
//    NSString *UserImgFilePath = [userIdFolder stringByAppendingPathComponent:@"icon.jpg"];
//    BOOL isImgFileCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserImgFilePath isDirectory:nil];
//    if (!isImgFileCreate)
//    {
//        NSString *HeadIMGstring = [NSString stringWithFormat:@"%@", [userInfoDir objectForKey:@"PicPath"]];
//        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
//        NSURL *url = [NSURL URLWithString:HeadIMGstring];
//        NSData *imageData = [NSData dataWithContentsOfURL:url];
//        [imageData writeToFile:UserImgFilePath atomically:YES];
//        [saveDefaults setObject:imageData forKey:@"headImg"];
//    }

}
//用UserId给每个用户创建本地文件夹
+ (NSString *)createFolder:(NSString *)folderNameStr
{
    NSFileManager *appFileManager = [NSFileManager defaultManager];
    NSString *userFolderPathTemp = [userFolderPath stringByAppendingPathComponent:folderNameStr];
    
    BOOL isUserFolderCreate = [appFileManager fileExistsAtPath:userFolderPathTemp isDirectory:nil];
    if (!isUserFolderCreate)
    {
        if (![appFileManager createDirectoryAtPath:userFolderPathTemp withIntermediateDirectories:YES attributes:nil error:nil])
        {
            NSLog(@"用户的文件创建失败");
        }
        else
        {
            return userFolderPathTemp;
        }
    }
    return userFolderPathTemp;
}

//KKNSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2)
+(void) NSLogKK:(NSString *)logMsg
{
    if([KKDebug isEqualToString:@"1"])
    {
        NSLog(@"%@",logMsg);
    }
}

+(void) showViewGrenct:(UIView*) tmpview:(NSString*)viewName
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGRect  frame=tmpview.frame;
    CGRect boand=tmpview.bounds;
    NSLog(@"当前UIScreen：width=%f height=%f－－－－－－－\n%@ frame大小为 ：x=%f,y=%f,width=%f,height=%f---\n bounds大小:x=%f;y=%f;width=%f;height=%f",screenBounds.size.width,screenBounds.size.height,viewName,frame.origin.x, frame.origin.y ,frame.size.width,frame.size.height
          ,boand.origin.x,boand.origin.y,boand.size.width,boand.size.height);
}

+(CGRect) CGRectMakeForAllIphone:(CGFloat) x:(CGFloat) y:(CGFloat) width:(CGFloat) height
{
    float autoSizeScaleX;
    float autoSizeScaleY;
    if(ScreenHeight > 480){
        autoSizeScaleX = ScreenWidth/320;
        autoSizeScaleY = ScreenHeight/568;
    }else{
        autoSizeScaleX = 1.0;
        autoSizeScaleY = 1.0;
    }
    CGRect rect;
    rect.origin.x = x * autoSizeScaleX;
    rect.origin.y = y * autoSizeScaleY;
    rect.size.width = width * autoSizeScaleX;
    rect.size.height = height * autoSizeScaleY;
    return rect;
}

@end