//
//  SquareTableViewController.m
//  h5
//
//  Created by hf on 15/4/16.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SquareTableViewController.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "SquareTableViewCell.h"
#import "h5kkContants.h"
#import "HomeInfoViewController.h"
#import "KKUtility.h"
#import "UserInfoTableViewController.h"
#import "CurrentUser.h"
#import "GameWebViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface SquareTableViewController ()
{
    AppDelegate *kkAppDelegate;
    NSDictionary *userInfo;
    
    NSMutableArray *adArray;
    NSMutableArray *playerArray;
    
    ASIFormDataRequest *request;
    
}
@end

@implementation SquareTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
     
    //广告
    [self initAdScrollView];
    
    //获取用户信息
    userInfo=[KKUtility getUserInfoFromLocalFile];
    
    //上下拉加载
    [self UpAndDownPull];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//上下拉加载
-(void)UpAndDownPull
{
    //首次进来下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        
        //加载广告滚动视图
        [weakSelf loadAd];
        
        //加载玩家动态
        [weakSelf loadPlayer];
    }];
    [self.tableView.legendHeader beginRefreshing];
    
//    [self.tableView addLegendFooterWithRefreshingBlock:^{
//        [weakSelf loadMoreData];
//    }];
}

//广告墙
-(void)initAdScrollView
{
    self.adScrollView.pagingEnabled = YES;
    self.adScrollView.delegate = self;
    self.adScrollView.bounces = NO;
    self.adScrollView.tag = 110;
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;
}

//----------------------------------------加载广告滚动视图------------------------------------------//
-(void)loadAd
{
    NSString *UserInfoFolder = [[kkAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"adView"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        //获取本地的广告
        adArray = [NSMutableArray arrayWithContentsOfFile:UserInfoFolder];
//        NSLog(@"本地adArray[%lu][%@]", (unsigned long)adArray.count, adArray);
    }

    //网络请求广告
    [self loadAdData];
}

//网络请求广告
-(void)loadAdData
{
    NSString *urlStr = GET_FLASH_LIST;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"0001" forKey:@"CateCode"];
    [request setDidFailSelector:@selector(loadAdDataFail:)];
    [request setDidFinishSelector:@selector(loadAdDataFinish:)];
    [request startAsynchronous];
}

- (void)loadAdDataFinish:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"loadAdDataFinish");
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadAdDataToSandBox:dic];
    }
    
    //结束刷新状态
    [self paintAd];
}

- (void)loadAdDataFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取首页动态失败 " :req.error];
    
    //结束刷新状态
    [self paintAd];
}

-(void)loadAdDataToSandBox:(NSDictionary *)dic
{
    adArray = [dic objectForKey:@"ObjData"];
//    NSLog(@"加载adArray[%lu][%@]", (unsigned long)adArray.count, adArray);
    
    NSString *UserInfoFolder = [[kkAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"adView"];
    if (![adArray writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存ad信息失败");
    }
}

//刷广告
-(void)paintAd
{
    self.pageControl.numberOfPages = adArray.count;
    for (int i = 0; i < adArray.count; i++)
    {
        NSDictionary *adDic = [adArray objectAtIndex:i];
        UIImageView *descImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.adScrollView.frame.size.width*i, 0, self.adScrollView.frame.size.width, self.adScrollView.frame.size.height)];
        [self.adScrollView addSubview:descImageView];
        [descImageView sd_setImageWithURL:[NSURL URLWithString:[adDic objectForKey:@"ImgUrl"]] placeholderImage:[UIImage imageNamed:@"mainBoard_adLogoDefault"]];
    }
    float widthall=self.adScrollView.frame.size.width*adArray.count;
    self.adScrollView.contentSize = CGSizeMake(widthall, self.adScrollView.frame.size.height);
     self.timeCount = 0;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
}

//定时滚动
-(void)scrollTimer{
    self.timeCount ++;
    self.pageControl.currentPage =  self.timeCount;
    if (self.timeCount == self.pageControl.numberOfPages) {
        self.timeCount = 0;
    }
    self.pageControl.currentPage = self.timeCount;
    self.scrollIndex=self.timeCount;
    float width=self.timeCount * self.adScrollView.frame.size.width;
    
    [self.adScrollView scrollRectToVisible:CGRectMake(width, 0, self.adScrollView.frame.size.width, self.adScrollView.frame.size.height) animated:YES];

  NSLog(@"antoScroll to:@%f",self.adScrollView.contentOffset.x);
}
//------------------------------UIScrollViewDelegate---------------------------------------------//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag == 110)
    {
        NSLog(@"%f",scrollView.contentOffset.x);
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        self.scrollIndex=pageIndex;
        NSLog(@"pageIndex[%d]", pageIndex);
//        if((self.scrollIndex+1)==self.pageControl.numberOfPages)
//        {
//            pageIndex=0;
//             [self.adScrollView scrollRectToVisible:CGRectMake(0, 0, self.adScrollView.frame.size.width, self.adScrollView.frame.size.height) animated:YES];
//        }
        self.pageControl.currentPage = pageIndex;
//        self.timeCount =pageIndex;
    }
}

-(void)scrollToNextPage:(id)sender
{
    NSInteger pageNum=self.pageControl.currentPage;
    CGSize viewSize=self.adScrollView.frame.size;
    CGRect rect=CGRectMake((pageNum+2)*viewSize.width, 0, viewSize.width, viewSize.height);
    [self.adScrollView scrollRectToVisible:rect animated:NO];
    pageNum++;
    if (pageNum==adArray.count) {
        CGRect newRect=CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
        [self.adScrollView scrollRectToVisible:newRect animated:NO];
    }
}
//----------------------------------------加载玩家动态----------------------------------------//
-(void)loadPlayer
{
    NSString *UserInfoFolder = [[kkAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"playerView"];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        //获取本地的玩家
        playerArray = [NSMutableArray arrayWithContentsOfFile:UserInfoFolder];
//        NSLog(@"本地playerArray[%lu][%@]", (unsigned long)playerArray.count, playerArray);
    }
    
    //网络请求玩家
    [self loadPlayerData];
}

//网络请求玩家
-(void)loadPlayerData
{
    NSString *urlStr = GET_NEW_USER;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:@"0" forKey:@"AreaId"];
    [request setPostValue:@"0" forKey:@"TimeIndex"];
    [request setDidFailSelector:@selector(loadPlayerDataFail:)];
    [request setDidFinishSelector:@selector(loadPlayerDataFinish:)];
    [request startAsynchronous];
}

- (void)loadPlayerDataFinish:(ASIHTTPRequest *)req
{
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"loadPlayerDataFinish");
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadPlayerDataToSandBox:dic];
    }
    
    //结束刷新状态
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

- (void)loadPlayerDataFail:(ASIHTTPRequest *)req
{
     [KKUtility showHttpErrorMsg:@"获取玩家信息失败 " :req.error];
    
    //结束刷新状态
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

-(void)loadPlayerDataToSandBox:(NSDictionary *)dic
{
    playerArray = [dic objectForKey:@"ObjData"];
//    NSLog(@"加载playerArray[%lu][%@]", (unsigned long)playerArray.count, playerArray);
    if([playerArray count]<1)
    {
        NSLog(@"获取到玩家动态数为0");
    }
    NSString *UserInfoFolder = [[kkAppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"playerView"];
    if (![playerArray writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存player信息失败");
    }
}

//---------------------------- Table view data source -------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return playerArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"squareCells";
    [tableView registerNib:[UINib nibWithNibName:@"SquareTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    SquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *playerDict = playerArray[indexPath.row];
    NSString *timeMsg=[KKUtility intervalSinceNow:[playerDict objectForKey:@"Key"]];
    
    NSString *strDistinct=[playerDict objectForKey:@"loc"];
    NSArray *dicArray = [strDistinct componentsSeparatedByString:@","];
    NSString *discLongitude=[[dicArray objectAtIndex:0] substringFromIndex:1];
    NSString *discLatitude=[[dicArray objectAtIndex:1] substringToIndex:[[dicArray objectAtIndex:1] length]-1];
    CLLocation *endpoint=[[CLLocation alloc] initWithLatitude:[discLongitude doubleValue]   longitude:[discLatitude doubleValue] ];//Latitude 纬度， longitude 经度
    
    NSString *TimeDistinctMsg=[timeMsg stringByAppendingString:[KKUtility calcutDistinct:kkAppDelegate.currentlogingUser.Location:endpoint]];
    
    
    cell.nameLable.text = [NSString stringWithFormat:@"%@", TimeDistinctMsg];
    cell.msgLabel.text = [playerDict objectForKey:@"KKMsg"];
    
    NSString *HeadIMGstring = [playerDict objectForKey:@"UserPic"];
    NSString *sHeadimg=[HeadIMGstring stringByReplacingOccurrencesOfString:@".jpg" withString:@"_s.jpg"];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:sHeadimg] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    CALayer * l = [cell.headImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)imagePressed:(id)sender
{
    NSDictionary *adDic = [adArray objectAtIndex:self.pageControl.currentPage];
    NSLog(@"查看网页详情[%@]", adDic);
    [self performSegueWithIdentifier:@"PushGameInfo" sender:adDic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *playerDict = playerArray[indexPath.row];
    NSString *strLinkType=[playerDict objectForKey:@"LinkType"];
    NSString *strLinkUrl=[playerDict objectForKey:@"LinkUrl"];
    NSString *strUserId=[playerDict objectForKey:@"UserId"];
    NSString *strLinkPara=[playerDict objectForKey:@"LinkPara"];
      //strLinkType 1.游戏      2.玩家        3.活动            4.截图
    if([strLinkType integerValue]==1)
    {
        //开始游戏
        NSDictionary *adDic=[NSDictionary dictionaryWithObjectsAndKeys:
                             strLinkUrl,@"Url",
                             strLinkPara,@"ContentPageID",nil ];
        NSLog(@"开始游戏[%@]", adDic);
        [self performSegueWithIdentifier:@"StartGameSegue" sender:adDic];
    }
    else if([strLinkType integerValue]==2)
    {
        //打开玩家界面
        NSDictionary *adDic=[NSDictionary dictionaryWithObject:strUserId forKey:@"UserId"];
        [self performSegueWithIdentifier:@"showFriendInfo" sender:adDic];
    }
    else// 3.活动 4.截图
    {
        NSDictionary *adDic=[NSDictionary dictionaryWithObject:strLinkUrl forKey:@"Url"];
        NSLog(@"查看网页详情[%@]", adDic);
        [self performSegueWithIdentifier:@"PushGameInfo" sender:adDic];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"StartGameSegue"])
    {
        GameWebViewController *gwvc = (GameWebViewController *)[segue destinationViewController];
        gwvc.gameDetailDict = (NSDictionary *)sender;
    }

    
    if([segue.identifier isEqualToString:@"PushGameInfo"])
    {
        HomeInfoViewController *gwvc = (HomeInfoViewController *)[segue destinationViewController];
        gwvc.gameInfoDict = (NSDictionary *)sender;
    }
    
    if([segue.identifier isEqualToString:@"showFriendInfo"])
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

-(BOOL)shouldAutorotate
{
    //传递入口3. 
    return [self.presentedViewController shouldAutorotate];
}
-(NSUInteger)supportedInterfaceOrientations
{
    return [self.presentedViewController supportedInterfaceOrientations];
}
@end



























