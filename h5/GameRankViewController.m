//
//  GameRankViewController.m
//  h5
//
//  Created by hf on 15/4/8.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "GameRankViewController.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "FrontRankTableViewCell.h"
#import "BehindTableViewCell.h"
#import "h5kkContants.h"
#import "KKUtility.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface GameRankViewController ()
{
    NSArray *menuNameArray;
    NSArray *worldRankArray;
    NSArray *chinaRankArray;
    NSArray *cityRankArray;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
}
@end

@implementation GameRankViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initContentScrollView];
    
    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    
    //加载排行榜数据
    [self loadRankData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)selectNameButton:(id)sender
{
    UIButton *selectBtn = (UIButton *)sender;
    
    [UIView animateWithDuration:0.15 animations:^{
        self.shadowView.frame = CGRectMake(selectBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                           selectBtn.frame.size.width, self.shadowView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished)
        {
            //点击后修改内容滚动
            NSInteger pageIndex = selectBtn.tag;
            [self.conScrollView setContentOffset:CGPointMake(pageIndex*self.conScrollView.frame.size.width, 0) animated:YES];
        }
    }];
}

-(void)initContentScrollView
{
    menuNameArray = @[@"WorldRankView", @"ChinaRankView",@"CityRankView"];
    self.conScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width,
                                                                       [UIScreen mainScreen].bounds.size.height-64)];
    self.conScrollView.pagingEnabled = YES;
    self.conScrollView.delegate = self;
    self.conScrollView.bounces = NO;
    self.conScrollView.tag = 110;
    self.conScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*menuNameArray.count, 0);
    [self.view addSubview:self.conScrollView];
//    NSLog(@"[%f][%f]", self.conScrollView.frame.size.width, self.conScrollView.frame.size.height);
    
    for (int i = 0; i < menuNameArray.count; i++)
    {
        UIView *conView = (UIView *)[[[NSBundle mainBundle]loadNibNamed:[menuNameArray objectAtIndex:i] owner:self options:nil] objectAtIndex:0];
        conView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*i, 0,
                                   self.conScrollView.frame.size.width, self.conScrollView.frame.size.height-44);
        [self.conScrollView addSubview:conView];
    }
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.worldRankTableView.tableFooterView = footLabel;
    self.chinaRankTableView.tableFooterView = footLabel;
    self.cityRankTableView.tableFooterView = footLabel;
}

//---------------------------------------------------------加载排行榜数据--------------------------------------------------------------//
-(void)loadRankData
{
//    //加载全球
//    [self loadworldRank];
//    
//    //加载中国
//    [self loadchinaRank];
//    
//    //加载同城
//    [self loadcityRank];
    
    NSString *urlStr = GET_GAME_RANK;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [self.gameDetailDict objectForKey:@"ContentPageID"]] forKey:@"GameId"];
    [request setPostValue:@"0" forKey:@"AreaId"];
    [request setPostValue:@"1" forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(loadRankFail:)];
    [request setDidFinishSelector:@selector(loadRankFinish:)];
    [request startAsynchronous];
}

- (void)loadRankFinish:(ASIHTTPRequest *)req
{
    NSLog(@"loadRankFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"loadRankdir[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadRankeData:dic];
    }
}

- (void)loadRankFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"加载排行数据失败 " :req.error];
}

//刷表
-(void)loadRankeData:(NSDictionary *)dic
{
    worldRankArray = [dic objectForKey:@"ObjData"];
    NSLog(@"+++[%lu]%@", (unsigned long)worldRankArray.count, worldRankArray);
}

//------------------------------UIScrollViewDelegate---------------------------------------------//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag == 110)
    {
        int pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        
        //滚动后修改顶部滚动条
        [UIView beginAnimations:nil context:NULL];
        if (pageIndex == 0)
        {
            self.shadowView.frame = CGRectMake(self.worldRankBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.worldRankBtn.frame.size.width, self.shadowView.frame.size.height);
        }
        if (pageIndex == 1)
        {
            self.shadowView.frame = CGRectMake(self.chinaRankBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.chinaRankBtn.frame.size.width, self.shadowView.frame.size.height);
        }
        if (pageIndex == 2)
        {
            self.shadowView.frame = CGRectMake(self.cityRankBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.cityRankBtn.frame.size.width, self.shadowView.frame.size.height);
        }
        [UIView commitAnimations];
    }
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 0)
    {
        return 2;
    }
    
    if(tableView.tag == 1)
    {
        return 1;
    }
    
    if(tableView.tag == 2)
    {
        return 8;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 0)
    {
        if(indexPath.row == 0)
        {
            static NSString *reuseIdentifier = @"frontRankCells";
            [tableView registerNib:[UINib nibWithNibName:@"FrontRankTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
            FrontRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            return cell;
        }
        
        static NSString *reuseIdentifier = @"behindRankCells";
        [tableView registerNib:[UINib nibWithNibName:@"BehindTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        BehindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    if(tableView.tag == 1)
    {
        if(indexPath.row == 0)
        {
            static NSString *reuseIdentifier = @"frontRankCells";
            [tableView registerNib:[UINib nibWithNibName:@"FrontRankTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
            FrontRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            return cell;
        }
        
        static NSString *reuseIdentifier = @"behindRankCells";
        [tableView registerNib:[UINib nibWithNibName:@"BehindTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        BehindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    if(tableView.tag == 2)
    {
        if(indexPath.row == 0)
        {
            static NSString *reuseIdentifier = @"frontRankCells";
            [tableView registerNib:[UINib nibWithNibName:@"FrontRankTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
            FrontRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            return cell;
        }
        
        static NSString *reuseIdentifier = @"behindRankCells";
        [tableView registerNib:[UINib nibWithNibName:@"BehindTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        BehindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 0)
    {
        if(indexPath.row == 0)
        {
            return 140;
        }
        return 80;
    }
    if(tableView.tag == 1)
    {
        if(indexPath.row == 0)
        {
            return 140;
        }
        return 80;
    }
    if(tableView.tag == 2)
    {
        if(indexPath.row == 0)
        {
            return 140;
        }
        return 80;
    }
    return 0;
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end






















