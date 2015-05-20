//
//  RadarViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "RadarViewController.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "KKUtility.h"
#import "AppDelegate.h"
#import "UIButton+ImageAndLabel.h"
#import "RadarAllTableViewController.h"
#import "UserInfoTableViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface RadarViewController ()
{
    NSDictionary *userInfo;
    NSMutableArray *AllAroundUserTmp;
}
@end

@implementation RadarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize radarSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.width);
    self.pulsingRadarView = [[PulsingRadarView alloc]initWithFrame:CGRectMake(0, ([[UIScreen mainScreen]bounds].size.height-radarSize.height)/2,radarSize.width, radarSize.height)];
    self.pulsingRadarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pulsingRadarView];
    //获取用户信息
    userInfo=[KKUtility getUserInfoFromLocalFile];
    
    //加载KK数据
    [self loadKKAROUND];
    
    //开始雷达
    self.items = [[NSMutableArray alloc]init];
    AllAroundUserTmp=[[NSMutableArray alloc]init];
    self.AllUsers=[[NSMutableArray alloc]init];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addOrReplaceItem) userInfo:nil repeats:YES];
}



//--------------------------------------加载KK数据-----------------------------------------------//
-(void)loadKKAROUND
{
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSString *urlStr = GET_KK_AROUND;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:@"1" forKey:@"pageindex"];
    NSString *Longitude=kkAppDelegate.currentlogingUser.Longitude;
    NSString *Latitude=kkAppDelegate.currentlogingUser.Latitude;
    [request setPostValue:Longitude forKey:@"lon"];
    [request setPostValue:Latitude forKey:@"lat"];
    [request setDidFailSelector:@selector(loadKKFail:)];
    [request setDidFinishSelector:@selector(loadKKFinish:)];
    [request startAsynchronous];
    NSLog(@"%@",request.url.path);
}

- (void)loadKKFinish:(ASIHTTPRequest *)request
{
    NSLog(@"loadKKFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"KKdict[%@]", dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        NSArray *data=[dict objectForKey:@"ObjData"];
        [AllAroundUserTmp addObjectsFromArray:data];
        
        [self.AllUsers addObjectsFromArray:data];
    }
}

- (void)loadKKFail:(ASIHTTPRequest *)request
{
    [KKUtility showHttpErrorMsg:@"获取kk雷达数据失败 " :request.error];
}
//--------------------------------------结束加载KK数据-----------------------------------------------//



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(replayRadar:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)addOrReplaceItem
{
    if([AllAroundUserTmp count]>0)
    {
        int maxCount = 10;
        NSDictionary *tmpuer=[AllAroundUserTmp objectAtIndex:0];
        UIButton *radarButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        NSString *HeadimgUrl = [tmpuer objectForKey:@"PicPath"];
        NSString *UserNickName=[tmpuer objectForKey:@"NickName"];
        NSString *UserId=[tmpuer objectForKey:@"UserId"];
        radarButton.tag=[UserId integerValue];
        
        NSString *existStr = @"_b.jpg";
        if ([HeadimgUrl rangeOfString:existStr].location == NSNotFound)
        {
            HeadimgUrl = [HeadimgUrl stringByReplacingOccurrencesOfString:@".jpg" withString:@"_b.jpg"];
        }
        //[radarButton sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        NSURL *url = [NSURL URLWithString:HeadimgUrl];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        if(image==nil)
        {
            image=[UIImage imageNamed:@"userDefaultHead"];
        }
        //[radarButton setImage:image forState:UIControlStateNormal];
        //[radarButton setTitle:UserNickName forState:UIControlStateNormal];
        CALayer * downButtonLayer = [radarButton layer];
        [downButtonLayer setMasksToBounds:YES];
        [downButtonLayer setCornerRadius:10.0];
        [radarButton setImage:image withTitle:UserNickName forState:UIControlStateNormal];
//      [downButtonLayer setBorderWidth:1.0];
//      [downButtonLayer setBorderColor:[[UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0] CGColor]];

        [radarButton addTarget:self action:@selector(ShowUserInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint center = self.generateCenterPointInRadar;
        radarButton.center = CGPointMake(center.x, center.y);
    
        if ([self itemFrameIntersectsInOtherItem:radarButton.frame])
        {
//       NSLog(@"重叠了");
            return;
        }
        else
        {
            [AllAroundUserTmp removeObjectAtIndex:0];

        }
    
        [self.pulsingRadarView addSubview:radarButton];
        [self.items addObject:radarButton];
    
        if(self.items.count > maxCount)
        {
            UIButton *btn = [self.items objectAtIndex:0];
        
            //渐变消失
            [UIView animateWithDuration:1.0 animations:^{
                btn.alpha = 0;
            } completion:^(BOOL finished) {
            [btn removeFromSuperview];
            [self.items removeObject:btn];
        }];
    }
    }
}

//返回一个圆内的中心坐标，这个坐标只会在圆的直径以内生成
-(CGPoint)generateCenterPointInRadar
{
    double angle = arc4random() % 360;
    double radius = arc4random() % (int)([[UIScreen mainScreen]bounds].size.width-44)/2;
    CGFloat x = cos(angle)*radius;
    CGFloat y = sin(angle)*radius;
    return CGPointMake(x + [[UIScreen mainScreen]bounds].size.width / 2, y + [[UIScreen mainScreen]bounds].size.width / 2);
}

//判断是否重叠
-(BOOL)itemFrameIntersectsInOtherItem:(CGRect)frame
{
    for (UIButton *btn in self.items)
    {
        if(CGRectIntersectsRect(btn.frame, frame))
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)replayRadar:(NSNotification *)notification
{
    if (self.pulsingRadarView.animationLayer)
    {
        [self.pulsingRadarView.animationLayer removeFromSuperlayer];
        [self.pulsingRadarView  setNeedsDisplay];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//退出
//- (IBAction)domissAction:(id)sender
//{
//    if (self.RVCdelegate && [self.RVCdelegate respondsToSelector:@selector(radarViewControllerDidClickedDismissButton:)])
//    {
//        [self.RVCdelegate radarViewControllerDidClickedDismissButton:self];
//    }
//}

//显示雷达全部
- (IBAction)showAllFriendInfo:(id)sender
{
    NSArray *Allusertmp=[self.AllUsers copy];
    [self performSegueWithIdentifier:@"showAllFriendInfo" sender:Allusertmp];
}
//显示用户信息
- (IBAction)ShowUserInfo:(id)sender
{
    NSString *Userid=[NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    NSDictionary *playerDict = [NSDictionary dictionaryWithObject:Userid forKey:@"UserId"];
    [self performSegueWithIdentifier:@"PushUserInfo" sender:playerDict];
    
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"showAllFriendInfo"])
    {
        RadarAllTableViewController *uitvc = (RadarAllTableViewController *)[segue destinationViewController];
        uitvc.radAllUsers = (NSArray *)sender;
    }
    if([segue.identifier isEqualToString:@"PushUserInfo"])
    {
        UserInfoTableViewController *uitvc = (UserInfoTableViewController *)[segue destinationViewController];
        uitvc.FriendInfoDict = (NSDictionary *)sender;
    }

    
}



@end



































