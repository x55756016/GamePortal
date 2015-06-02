//
//  GameDetailViewController.m
//  h5
//
//  Created by hf on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "GameDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "GameRankViewController.h"
#import "GameWebViewController.h"
#import "ASIFormDataRequest.h"
#import "h5kkContants.h"
#import "KKUtility.h"

@interface GameDetailViewController ()
{
    NSArray *descImgArr;
    ASIFormDataRequest *request;

}
@end

@implementation GameDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self GetGameInfoFromServer];
}
-(void)viewWillAppear:(BOOL)animated
{
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态没有效果
}
-(void)viewWillLayoutSubviews
{
          [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态没有效果
}

//------------------------------开始获取游戏详情-----------------
-(void)GetGameInfoFromServer
{
    NSString *gameId = [NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]];
    
    
    NSString *urlStr = Get_GameDetailInfo;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:15.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:gameId forKey:@"pageId"];
    [request setDidFailSelector:@selector(GetGameInfoFromServerFail:)];
    [request setDidFinishSelector:@selector(GetGameInfoFromServerFinish:)];
    [request startAsynchronous];
    
}
- (void)GetGameInfoFromServerFinish:(ASIHTTPRequest *)req
{
    @try {
        
        NSError *error;
        NSData *responseData = [req responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        //    NSLog(@"requestUserGame[%@]",dic);
        
        if([[dic objectForKey:@"IsSuccess"] integerValue])
        {
            NSArray *data= [dic objectForKey:@"ObjData"];
            self.gameDetailDict =[data objectAtIndex:0];
            [[self tableView] reloadData];
            [self initContentScrollView];
        }
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg: exception.reason :nil];
    }
}
- (void)GetGameInfoFromServerFail:(ASIHTTPRequest *)req
{
   [KKUtility showHttpErrorMsg:@"获取游戏详情失败 " :req.error];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initContentScrollView
{
    //加载游戏描述图片
    [self loadGameDescImg];
    
    CGFloat scrollViewX = ([UIScreen mainScreen].bounds.size.width-180)/2;
    UIView *picView = [[UIView alloc]initWithFrame:CGRectMake(scrollViewX, 41, 180, 240)];
    [self.contentTableViewCell.contentView addSubview:picView];
    
    self.conScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, picView.frame.size.width, picView.frame.size.height)];
    self.conScrollView.pagingEnabled = YES;
    self.conScrollView.delegate = self;
    self.conScrollView.bounces = NO;
    self.conScrollView.tag = 110;
    self.conScrollView.contentSize = CGSizeMake(picView.frame.size.width*descImgArr.count, 0);
    [picView addSubview:self.conScrollView];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 200, 180, 40)];
    self.pageControl.numberOfPages = descImgArr.count;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    [picView addSubview:self.pageControl];
    
    for (int i = 0; i < descImgArr.count; i++)
    {
        NSString *descImageStr = [descImgArr objectAtIndex:i];
        UIImageView *descImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.conScrollView.frame.size.width*i, 0, self.conScrollView.frame.size.width, self.conScrollView.frame.size.height)];
        [self.conScrollView addSubview:descImageView];
        [descImageView sd_setImageWithURL:[NSURL URLWithString:descImageStr] placeholderImage:[UIImage imageNamed:@""]];
    }
}

-(void)loadGameDescImg
{
    NSString *descImgStr = [self.gameDetailDict objectForKey:@"DescImg"];
    descImgArr = [descImgStr componentsSeparatedByString:@"||"];
//    NSLog(@"descImgArr[%d][%@]", descImgArr.count, descImgArr);
}

- (IBAction)playGame:(id)sender
{
    NSLog(@"开始游戏[%@]", self.gameDetailDict);
    [self performSegueWithIdentifier:@"PushWebGame" sender:self.gameDetailDict];
}

//------------------------------UIScrollViewDelegate---------------------------------------------//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag == 110)
    {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
//        NSLog(@"pageIndex[%d]", pageIndex);
        self.pageControl.currentPage = pageIndex;
    }
}

//------------------------------Table view data source----------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    
    else if(section == 1)
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
            cell = self.HeadTableViewCell;
            self.gameNameLabel.text = [self.gameDetailDict objectForKey:@"Title"];
            self.gameDesLabel.text = [self.gameDetailDict objectForKey:@"Summary"];
            self.gameDetailDesLabel.text = [self.gameDetailDict objectForKey:@"Body"];
            self.gameDetailDesLabel.numberOfLines = 0;
            NSString *HeadIMGstring = [self.gameDetailDict objectForKey:@"Logo"];
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.contentTableViewCell;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushGameRank"])
    {
        GameRankViewController *grvc = (GameRankViewController *)[segue destinationViewController];
        grvc.gameDetailDict = self.gameDetailDict;
    }
    
    if([segue.identifier isEqualToString:@"PushWebGame"])
    {
        GameWebViewController *gwvc = (GameWebViewController *)[segue destinationViewController];
        gwvc.gameDetailDict = (NSDictionary *)sender;
    }
}
- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}

@end
































