//
//  DataModifyTableViewController.m
//  h5
//
//  Created by wwj on 15/4/2.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "DataModifyTableViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface DataModifyTableViewController ()
{
    AppDelegate *appDelegate;
    NSDictionary *userInfo;
    NSData *uploadImageData;
    NSString *currentTimeStr;
    
    ASIFormDataRequest *request;
}
@end

@implementation DataModifyTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.headImageView.frame = CGRectMake(self.headImageView.frame.origin.x, self.headImageView.frame.origin.y, 60, 60);
    self.headImageView.layer.cornerRadius = CGRectGetHeight([self.headImageView bounds])/2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)selectHeadImageTapGesAction:(id)sender
{
    NSLog(@"点击头像,后面增加放大查看功能");
}

//本地获取用户信息
-(void)getUserInfo
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        userInfo = [NSDictionary dictionaryWithContentsOfFile:UserInfoFolder];
//        NSLog(@"userInfo[%@]", userInfo);
        
        //头像
        [self getUserIcon];
        
        self.idCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]];
        self.rankCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"VipLevel"]];
        self.nickNameCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"NickName"]];
        self.ageCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Age"]];
        self.signatureCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sign"]];
        
        NSString *locationStr = [[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Province"]] stringByAppendingString:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"City"]]];
        if([locationStr isEqualToString:@""])
        {
            self.locationCell.detailTextLabel.text = @"请填写";
        }
        else
        {
            self.locationCell.detailTextLabel.text = locationStr;
        }
        
        if([[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sex"]] isEqualToString:@"0"])
        {
            self.sexCell.detailTextLabel.text = @"男";
        }
        else
        {
            self.sexCell.detailTextLabel.text = @"女";
        }
    }
    
    [self.tableView reloadData];
}

-(void)getUserIcon
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"icon.jpg"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        self.headImageView.image = [UIImage imageWithContentsOfFile:UserInfoFolder];
    }
    else
    {
        NSString *HeadIMGstring = [userInfo objectForKey:@"PicPath"];
        HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    }
}

//-----------------------------UIImagePickerControllerDelegate-----------------------------------------------------//
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSString *kUTType = (NSString *)kUTTypeImage;
    
    if([mediaType isEqualToString:kUTType])
    {
        UIImage *headImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        uploadImageData = UIImageJPEGRepresentation(headImage, 0.1);
        self.headImageView.image = [UIImage imageWithData:uploadImageData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //保存头像至本地
            [self savePic:uploadImageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//保存头像至本地
-(void)savePic:(NSData *)imageData
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *imageFolder = [userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]];
    NSString *imageName = [imageFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"icon.jpg"]];
    [imageData writeToFile:imageName atomically:YES];
    [saveDefaults setObject:imageData forKey:@"headImg"];
    
    //时间戳
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMddHHmmmm"];
    currentTimeStr = [df stringFromDate:currentDate];
    
    //路径保存好
    NSString *uploadimgStr = @"http://pic.h5kk.com/uploadimg";
    NSString *useridStr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]];
    NSString *uploadimgPathStr = [NSString stringWithFormat:@"%@/%@", uploadimgStr, useridStr];
    NSString *uploadimgPath = [NSString stringWithFormat:@"%@/pic_%@.jpg", uploadimgPathStr, currentTimeStr];
    [userInfo setValue:uploadimgPath forKey:@"PicPath"];
    [self saveUserInfo];
    
    //上传头像至服务器
    [self upLoadToServer];
}

//上传头像至服务器
-(void)upLoadToServer
{
    //userid
    NSString *useridStr = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://pic.h5kk.com/fileupload.php?id=%@&index=%@", useridStr, currentTimeStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:20.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setDidFailSelector:@selector(upLoadheadFail:)];
    [request setDidFinishSelector:@selector(upLoadheadFinish:)];
    [request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
    [request addData:uploadImageData forKey:@"upfile"];
    [request startAsynchronous];
}

- (void)upLoadheadFinish:(ASIHTTPRequest *)req
{
    NSLog(@"上传头像成功");
    
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"upLoadheaddir[%@]",dic);
}

- (void)upLoadheadFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"上传头像失败 " :req.error];

}

//上传所有信息至服务器
-(void)upLoadAllInfoToServer
{
    NSString *urlStr = USER_INFO_EDIT;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"NickName"]] forKey:@"NickName"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Email"]] forKey:@"Email"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Age"]] forKey:@"Age"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sign"]] forKey:@"Sign"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sex"]] forKey:@"Sex"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"PicPath"]] forKey:@"PicPath"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Province"]] forKey:@"Province"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"City"]] forKey:@"City"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Address"]] forKey:@"Address"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"requestFinishedDic%@", dic);
    
    [SVProgressHUD dismiss];
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存成功"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        NSString *msgStr = [dic objectForKey:@"Msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存失败"
                                                        message:msgStr
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存失败"
                                                    message:@"请检查网络后重试"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//-----------------------UITableViewDataSource-----------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 5;
    }
    
    else if(section == 1)
    {
        return 4;
    }
    
    else if(section == 2)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell = self.headPathCell;
        }
        
        if(indexPath.row == 1)
        {
            cell = self.idCell;
        }
        
        if(indexPath.row == 2)
        {
            cell = self.rankCell;
        }
        
        if(indexPath.row == 3)
        {
            cell = self.nickNameCell;
        }
        
        if(indexPath.row == 4)
        {
            cell = self.ageCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.sexCell;
        }
        if(indexPath.row == 1)
        {
            cell = self.signatureCell;
        }
        if(indexPath.row == 2)
        {
            cell = self.locationCell;
        }
        if(indexPath.row == 3)
        {
            cell = self.loveCell;
        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.saveCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:@"取消"
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"拍照", @"从手机相册选择", nil];
            [actionSheet showInView:self.view];
        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
            {
                //上传所有信息至服务器
                [self upLoadAllInfoToServer];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络后重试"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

//----------------------------------UIActionSheetDelegate----------------------------------------//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 2)
    {
        return;
    }
    
    //拍照
    if(buttonIndex == 0)
    {
        //有摄像头
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
    }

    //从照片选
    if(buttonIndex == 1)
    {
        [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }

    [self.imagePicker setDelegate:self];
    self.imagePicker.navigationBar.barTintColor = [UIColor blackColor];
    self.imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    self.imagePicker.navigationBar.barStyle = UIBarStyleBlack;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushName"])
    {
        MeDetailNameTableViewController *mdntvc = (MeDetailNameTableViewController *)[segue destinationViewController];
        mdntvc.MDNTVCdelegate = self;
        mdntvc.nameSegueString = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"NickName"]];
    }
    
    if([segue.identifier isEqualToString:@"PushAge"])
    {
        MeDetailAgeTableViewController *mdntvc = (MeDetailAgeTableViewController *)[segue destinationViewController];
        mdntvc.MDATVCdelegate = self;
        mdntvc.ageSegueString = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Age"]];
    }
    
    if([segue.identifier isEqualToString:@"PushSex"])
    {
        MeDetailSexTableViewController *mdstvc = (MeDetailSexTableViewController *)[segue destinationViewController];
        mdstvc.MDSTVCdelegate = self;
        mdstvc.sexSegueString = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sex"]];
    }
    
    if([segue.identifier isEqualToString:@"PushLocal"])
    {
        MeDetailLocalTableViewController *mdltvc = (MeDetailLocalTableViewController *)[segue destinationViewController];
        mdltvc.userInfo = userInfo;
    }
    
    if([segue.identifier isEqualToString:@"PushSignature"])
    {
        SignatureTableViewController *stvc = (SignatureTableViewController *)[segue destinationViewController];
        stvc.signatureSegueString = [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"Sign"]];
        stvc.userInfo = userInfo;
    }
}

//---------------------------------------MeDetailNameTableViewControllerDelegate--------------------------------//
-(void)meDetailNameTableViewControllerCancle:(MeDetailNameTableViewController *)meDetailNameTableViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)meDetailNameTableViewControllerSave:(MeDetailNameTableViewController *)meDetailNameTableViewController
{
    [userInfo setValue:meDetailNameTableViewController.nameSegueString forKey:@"NickName"];
    [self saveUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

//---------------------------------------MeDetailSexTableViewControllerDelegate--------------------------------//
-(void)meDetailSexTableViewControllerSave:(MeDetailSexTableViewController *)meDetailSexTableViewController
{
    [userInfo setValue:meDetailSexTableViewController.sexSegueString forKey:@"Sex"];
    [self saveUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

//---------------------------------------MeDetailAgeTableViewControllerDelegate--------------------------------//
-(void)meDetailAgeTableViewControllerCancle:(MeDetailAgeTableViewController *)meDetailAgeTableViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)meDetailAgeTableViewControllerSave:(MeDetailAgeTableViewController *)meDetailAgeTableViewController
{
    [userInfo setValue:meDetailAgeTableViewController.ageSegueString forKey:@"Age"];
    [self saveUserInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveUserInfo
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![userInfo writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存用户信息失败");
    }
}
- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end
























