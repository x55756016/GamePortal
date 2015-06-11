//
//  FindAroundTableViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "FindAroundTableViewController.h"
#import "AroundTableViewCell.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "UserInfoTableViewController.h"
#import "KKUtility.h"
#import "AppDelegate.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface FindAroundTableViewController ()
{
    NSMutableArray *aroundArray;
    NSArray *FriendTempArray;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
    NSInteger pageIndex;
    BOOL addData;
}
@end

@implementation FindAroundTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    aroundArray=[NSMutableArray array];
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;
    
    //获取用户信息
    userInfo = [KKUtility getUserInfoFromLocalFile];
    

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusNotDetermined== status
        || kCLAuthorizationStatusDenied == status
        || kCLAuthorizationStatusRestricted == status) {
        //判断是否开启定位
//        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//        if(IS_iOS8){
//            [locationManager requestWhenInUseAuthorization];
//        }
        [KKUtility justAlert:@"请手工开启定位:设置 > 隐私 > 位置 > 定位服务 找到 KK玩 设置为始终,否则无法查找附近的好友。"];
        return;
    }
    
    //首次进来下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{        
        //加载附近数据
        pageIndex=1;
        addData=false;
        [weakSelf loadAround];
    }];
    [self.tableView.legendHeader beginRefreshing];

    [self.tableView addLegendFooterWithRefreshingBlock:^{
        pageIndex=pageIndex+1;
        addData=true;
        [weakSelf loadAround];
    }];


}
-(void)viewWillAppear:(BOOL)animated
{
    pageIndex=1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//--------------------------------------加载附近数据-----------------------------------------------//
-(void)loadAround
{
    NSString *urlStr = GET_AROUND;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%ld",(long)pageIndex] forKey:@"pageindex"];
    
    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString *strlon=kkAppDelegate.currentlogingUser.Longitude;//经度
    NSString *strlat=kkAppDelegate.currentlogingUser.Latitude;//纬度
    
    [request setPostValue:strlon forKey:@"lon"];
    [request setPostValue:strlat forKey:@"lat"];

    [request setDidFailSelector:@selector(loadAroundFail:)];
    [request setDidFinishSelector:@selector(loadAroundFinish:)];
    [request startAsynchronous];
}

- (void)loadAroundFinish:(ASIHTTPRequest *)req
{
    NSLog(@"loadAroundFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"Arounddict[%@]", dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        FriendTempArray = [dict objectForKey:@"ObjData"];
        if(addData)
        {
            [aroundArray addObjectsFromArray:FriendTempArray];
        }else
        {
            [aroundArray removeAllObjects];
            [aroundArray addObjectsFromArray:FriendTempArray];
        }
    }
    
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

- (void)loadAroundFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"加载附近数据失败" :req.error];
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aroundArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"aroundCells";
    [tableView registerNib:[UINib nibWithNibName:@"AroundTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    AroundTableViewCell *aroundTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *friendsDict = aroundArray[indexPath.row];
    aroundTableViewCell.nickNameLabel.text = [friendsDict objectForKey:@"NickName"];
    aroundTableViewCell.signLabel.text = [friendsDict objectForKey:@"Sign"];
    
    NSNumber * myNumber=[friendsDict objectForKey:@"dis"];
    NSString *strDis=[NSString stringWithFormat:@"%.2f",[myNumber floatValue]];
    
    aroundTableViewCell.disLabel.text = [NSString stringWithFormat:@"%@km", strDis];
    
    NSString *HeadIMGstring = [friendsDict objectForKey:@"PicPath"];
    HeadIMGstring =[KKUtility getKKImagePath:HeadIMGstring :@"s"];
    [aroundTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    
    CALayer * l = [aroundTableViewCell.headImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];

    
    return aroundTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *userInfoDict = aroundArray[indexPath.row];
    [self performSegueWithIdentifier:@"PushUserInfo" sender:userInfoDict];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushUserInfo"])
    {
        UserInfoTableViewController *uitvc = (UserInfoTableViewController *)[segue destinationViewController];
        uitvc.FriendInfoDict = (NSDictionary *)sender;
    }
}
- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end



























