//
//  GameViewController.m
//  h5
//
//  Created by hf on 15/3/30.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "GameListViewController.h"
#import "GameTableViewCell.h"
#import "ClassifyTableViewCell.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "GameDetailViewController.h"
#import "MoreGameViewController.h"
#import "MJRefresh.h"
#import "GameWebViewController.h"
#import "h5kkContants.h"
#import "KKUtility.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface GameListViewController ()
{
    NSArray *menuNameArray;
    NSDictionary *userInfo;
    
    NSMutableArray *hotGameArray;
    int hotGamePageIndex;
    
    NSMutableArray *myGameArray;
    int myGamePageIndex;
    
    NSMutableArray *classifyArray;
    int classifyPageIndex;
    
    ASIFormDataRequest *request;
}
@end

@implementation GameListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    int pageIndex = 1;
    hotGamePageIndex = pageIndex;
    myGamePageIndex = pageIndex;
    classifyPageIndex = pageIndex;
    
    //设置滚动视图
    [self initContentScrollView];
    
    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    
    //上下拉加载
    [self UpAndDownPull];
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
    menuNameArray = @[@"HotGameView", @"MyGame",@"Classify"];
    self.conScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];//[UIScreen mainScreen].bounds.size.height-49-64)];
    self.conScrollView.pagingEnabled = YES;
    self.conScrollView.delegate = self;
    self.conScrollView.bounces = NO;
    self.conScrollView.showsHorizontalScrollIndicator = NO;
    self.conScrollView.tag = 110;
    self.conScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*menuNameArray.count, 0);
    [self.view addSubview:self.conScrollView];
//    NSLog(@"[%f][%f][%f][%f]", self.conScrollView.frame.origin.x, self.conScrollView.frame.origin.y, self.conScrollView.frame.size.width, self.conScrollView.frame.size.height);

//    for (int i = 0; i < menuNameArray.count; i++)
    for (int i = 0; i < 1; i++)
    {
        UIView *conView = (UIView *)[[[NSBundle mainBundle]loadNibNamed:[menuNameArray objectAtIndex:i] owner:self options:nil] objectAtIndex:0];
        conView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*i, 0,
                                        self.conScrollView.frame.size.width, self.conScrollView.frame.size.height-44);
        [self.conScrollView addSubview:conView];
    }
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.hotGameTableView.tableFooterView = footLabel;
    self.myGameTableView.tableFooterView = footLabel;
    self.classifyTableView.tableFooterView = footLabel;
}

//加载的数据保存至本地
-(void)saveGameDate:(int)gameType
{
//    NSLog(@"gameType[%d]", gameType);
    
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = [menuNameArray objectAtIndex:gameType];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    if(gameType == 0)
    {
        if (![hotGameArray writeToFile:UserInfoFolder atomically:YES])
        {
            NSLog(@"保存热门游戏信息失败");
        }
    }
    if(gameType == 1)
    {
        if (![myGameArray writeToFile:UserInfoFolder atomically:YES])
        {
            NSLog(@"保存我的游戏信息失败");
        }
    }
    if(gameType == 2)
    {
        if (![classifyArray writeToFile:UserInfoFolder atomically:YES])
        {
            NSLog(@"保存游戏分类信息失败");
        }
    }
}

//上下拉加载
-(void)UpAndDownPull
{
    //首次进来下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.hotGameTableView addLegendHeaderWithRefreshingBlock:^{
        //加载热门游戏数据
        [weakSelf loadHotGame];
    }];
    [self.hotGameTableView.legendHeader beginRefreshing];
    [self.hotGameTableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadMoreData:0];
    }];
    
    //加载我的游戏数据
    [self loadMyGame];
    [self.myGameTableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadMyGame];
    }];
    [self.myGameTableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadMoreData:1];
    }];
    
    //加载游戏分类数据
    [self loadGameClassify];
    [self.classifyTableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadGameClassify];
    }];
    [self.classifyTableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadMoreData:2];
    }];
}

//加载更多数据
- (void)loadMoreData:(int)type
{
    switch (type)
    {
        case 0:
            [self loadHotGameConfig];
            break;
        case 1:
            [self loadMyGameConfig];
            break;
        case 2:
            [self loadGameClassifyConfig];
            break;
        default:
            break;
    }
}

//--------------------------------------------加载热门游戏数据------------------------------------------//
-(void)loadHotGame
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = [menuNameArray objectAtIndex:0];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        //下拉刷新永远请求第一页(PageIndex==1)的数据
        hotGameArray = [NSMutableArray arrayWithContentsOfFile:UserInfoFolder];
        hotGamePageIndex = 1;
        NSLog(@"本地hotGame[%lu]PageIndex[%d]", (unsigned long)hotGameArray.count, hotGamePageIndex);
    }
    [self loadHotGameConfig];
}

-(void)loadHotGameConfig
{
    NSString *urlStr = GET_GAME_LIST;
    NSURL *url = [NSURL URLWithString:urlStr];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:@"4" forKey:@"iCategoryId"];
    [request setPostValue:[NSString stringWithFormat:@"%d", hotGamePageIndex] forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(loadHotGameFail:)];
    [request setDidFinishSelector:@selector(loadHotGameFinish:)];
    [request startAsynchronous];
}

- (void)loadHotGameFinish:(ASIHTTPRequest *)req
{
//    NSLog(@"loadHotGameFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadHotGameData:dic];
    }
    
    //结束刷新状态
    [self.hotGameTableView reloadData];
    [self.hotGameTableView.header endRefreshing];
    [self.hotGameTableView.footer endRefreshing];
}

- (void)loadHotGameFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"获取热门游戏失败" :req.error];
    //结束刷新状态
    [self.hotGameTableView reloadData];
    [self.hotGameTableView.header endRefreshing];
    [self.hotGameTableView.footer endRefreshing];
}

//热门游戏数据刷表
-(void)loadHotGameData:(NSDictionary *)dic
{
    NSMutableArray *newArray = [dic objectForKey:@"ObjData"];
    
    if(hotGamePageIndex > 1)
    {
        if(hotGameArray == nil)
        {
            hotGameArray = newArray;
        }
        else
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObjectsFromArray:hotGameArray];
            [tempArray addObjectsFromArray:newArray];
            hotGameArray = tempArray;
        }
        hotGamePageIndex += 1;
    }
    else
    {
        hotGameArray = newArray;
        if(hotGameArray.count >= 20)
        {
            hotGamePageIndex += 1;
        }
    }
    NSLog(@"加载hotGame[%lu]PageIndex[%d]", (unsigned long)hotGameArray.count, hotGamePageIndex);
    
    //加载的数据保存至本地
    [self saveGameDate:0];
}

//--------------------------------------------加载我的游戏数据--------------------------------------------//
-(void)loadMyGame
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = [menuNameArray objectAtIndex:1];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        //下拉刷新永远请求第一页(PageIndex==1)的数据
        myGameArray = [NSMutableArray arrayWithContentsOfFile:UserInfoFolder];
        myGamePageIndex = 1;
        NSLog(@"本地myGameArray[%lu]PageIndex[%d]", (unsigned long)myGameArray.count, myGamePageIndex);
    }
    [self loadMyGameConfig];
}

-(void)loadMyGameConfig
{
    NSString *urlStr = GET_MY_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"PlayerId"];
    [request setPostValue:[NSString stringWithFormat:@"%d", myGamePageIndex] forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(loadMyGameFail:)];
    [request setDidFinishSelector:@selector(loadMyGameFinish:)];
    [request startAsynchronous];
}

- (void)loadMyGameFinish:(ASIHTTPRequest *)req
{
//    NSLog(@"loadMyGameFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"MyGame[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadMyGameData:dic];
    }
    
    //结束刷新状态
    [self.myGameTableView reloadData];
    [self.myGameTableView.header endRefreshing];
    [self.myGameTableView.footer endRefreshing];
}

- (void)loadMyGameFail:(ASIHTTPRequest *)req
{
//    NSLog(@"loadMyGameFail");
    [KKUtility showHttpErrorMsg:@"获取我的游戏失败 " :req.error];
    //结束刷新状态
    [self.myGameTableView reloadData];
    [self.myGameTableView.header endRefreshing];
    [self.myGameTableView.footer endRefreshing];
}

//我的游戏数据刷表
-(void)loadMyGameData:(NSDictionary *)dic
{
    NSMutableArray *newArray = [dic objectForKey:@"ObjData"];
    
    if(myGamePageIndex > 1)
    {
        if(myGameArray == nil)
        {
            myGameArray = newArray;
        }
        else
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObjectsFromArray:myGameArray];
            [tempArray addObjectsFromArray:newArray];
            myGameArray = tempArray;
        }
        myGamePageIndex += 1;
    }
    else
    {
        myGameArray = newArray;
        if(myGameArray.count >= 20)
        {
            myGamePageIndex += 1;
        }
    }
    NSLog(@"加载myGame[%lu]PageIndex[%d]", (unsigned long)myGameArray.count, myGamePageIndex);
    
    //加载的数据保存至本地
    [self saveGameDate:1];
}

//----------------------------------------加载游戏分类数据------------------------------------------//
-(void)loadGameClassify
{
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dataListName = [menuNameArray objectAtIndex:2];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:dataListName];
    
    BOOL isUserInfoFolderCreate = [[NSFileManager defaultManager] fileExistsAtPath:UserInfoFolder isDirectory:nil];
    if (isUserInfoFolderCreate)
    {
        //下拉刷新永远请求第一页(PageIndex==1)的数据
        classifyArray = [NSMutableArray arrayWithContentsOfFile:UserInfoFolder];
        classifyPageIndex = 1;
        NSLog(@"本地classifyArray[%lu]PageIndex[%d]", (unsigned long)classifyArray.count, classifyPageIndex);
    }
    [self loadGameClassifyConfig];
}

-(void)loadGameClassifyConfig
{
    NSString *urlStr = GET_GAME_TYPE;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:@"003" forKey:@"CateCode"];
    [request setPostValue:[NSString stringWithFormat:@"%d", classifyPageIndex] forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(loadGameClassifyFail:)];
    [request setDidFinishSelector:@selector(loadGameClassifyFinish:)];
    [request startAsynchronous];
}

- (void)loadGameClassifyFinish:(ASIHTTPRequest *)req
{
//    NSLog(@"loadGameClassifyFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"[%@]",dic);
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadGameClassifyData:dic];
    }
    
    //结束刷新状态
    [self.classifyTableView reloadData];
    [self.classifyTableView.header endRefreshing];
    [self.classifyTableView.footer endRefreshing];
}

- (void)loadGameClassifyFail:(ASIHTTPRequest *)req
{
//    NSLog(@"loadGameClassifyFail");
    [KKUtility showHttpErrorMsg:@"获取游戏分类信息失败 " :req.error];
    //结束刷新状态
    [self.classifyTableView reloadData];
    [self.classifyTableView.header endRefreshing];
    [self.classifyTableView.footer endRefreshing];
}

//游戏类别数据刷表
-(void)loadGameClassifyData:(NSDictionary *)dic
{
    NSMutableArray *newArray = [dic objectForKey:@"ObjData"];
    
    if(classifyPageIndex > 1)
    {
        if(classifyArray == nil)
        {
            classifyArray = newArray;
        }
        else
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObjectsFromArray:classifyArray];
            [tempArray addObjectsFromArray:newArray];
            classifyArray = tempArray;
        }
        classifyPageIndex += 1;
    }
    else
    {
        classifyArray = newArray;
        if(classifyArray.count >= 20)
        {
            classifyPageIndex += 1;
        }
    }
    NSLog(@"加载classify[%lu]PageIndex[%d]", (unsigned long)classifyArray.count, classifyPageIndex);
    
    //加载的数据保存至本地
    [self saveGameDate:2];
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
            self.shadowView.frame = CGRectMake(self.hotGameBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.hotGameBtn.frame.size.width, self.shadowView.frame.size.height);
        }
        if (pageIndex == 1)
        {
            self.shadowView.frame = CGRectMake(self.myGameBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.myGameBtn.frame.size.width, self.shadowView.frame.size.height);
        }
        if (pageIndex == 2)
        {
            self.shadowView.frame = CGRectMake(self.ClassifyBtn.frame.origin.x, self.shadowView.frame.origin.y,
                                               self.ClassifyBtn.frame.size.width, self.shadowView.frame.size.height);
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
        return hotGameArray.count;
    }
    
    if(tableView.tag == 1)
    {
        return myGameArray.count;
    }
    
    if(tableView.tag == 2)
    {
        return classifyArray.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 0)
    {
        static NSString *reuseIdentifier = @"gameCells";
        [tableView registerNib:[UINib nibWithNibName:@"GameTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        NSDictionary *hotGameDict = hotGameArray[indexPath.row];
//        NSLog(@"hotGameDict[%@]", hotGameDict);
        cell.gameNameLabel.text = [hotGameDict objectForKey:@"Title"];
        cell.gameDesLabel.text = [hotGameDict objectForKey:@"Summary"];
        cell.playGameBtn.tag=indexPath.row;
        [cell.playGameBtn addTarget:self action:@selector(StartplayGame:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *HeadIMGstring = [hotGameDict objectForKey:@"Logo"];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        return cell;
    }
    
    if(tableView.tag == 1)
    {
        static NSString *reuseIdentifier = @"gameCells";
        [tableView registerNib:[UINib nibWithNibName:@"GameTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        NSDictionary *myGameDict = myGameArray[indexPath.row];
//        NSLog(@"myGameDict[%@]", myGameDict);
        cell.gameNameLabel.text = [myGameDict objectForKey:@"Title"];
        cell.gameDesLabel.text = [myGameDict objectForKey:@"Summary"];
        cell.playGameBtn.tag=indexPath.row;
        [cell.playGameBtn addTarget:self action:@selector(StartplayGame:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *HeadIMGstring = [myGameDict objectForKey:@"Logo"];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        return cell;
    }
    
    if(tableView.tag == 2)
    {
        static NSString *reuseIdentifier = @"classifyCells";
        [tableView registerNib:[UINib nibWithNibName:@"ClassifyTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        ClassifyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        NSDictionary *classifyDict = classifyArray[indexPath.row];
//        NSLog(@"classifyDict[%@]", classifyDict);
        cell.gameNameLabel.text = [classifyDict objectForKey:@"Title"];
        [cell.moreBtn addTarget:self action:@selector(checkMore:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *HeadIMGstring = [classifyDict objectForKey:@"AdImg"];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView.tag == 0)
    {
        NSDictionary *hotGameDict = hotGameArray[indexPath.row];
        NSLog(@"查看热门游戏详情[%@]", hotGameDict);
        [self performSegueWithIdentifier:@"showGameDetail" sender:hotGameDict];
    }
//
//    if(tableView.tag == 1)
//    {
//        NSDictionary *myGameDict = myGameArray[indexPath.row];
//        NSLog(@"查看我的游戏详情[%@]", myGameDict);
//        [self performSegueWithIdentifier:@"PushGameDetail" sender:myGameDict];
//    }
//    
//    if(tableView.tag == 2)
//    {
//        NSDictionary *classifyGameDict = classifyArray[indexPath.row];
//        NSLog(@"查看更多游戏[%@]", classifyGameDict);
//        [self performSegueWithIdentifier:@"PushMoreGame" sender:classifyGameDict];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

//---------------------------------------开始游戏----------------------------------------------//
- (IBAction)StartplayGame:(id)sender
{
    UIButton *button = (UIButton *)sender;
     NSInteger indexRow=button.tag;
    
    
    GameTableViewCell *cell = (GameTableViewCell *)button.superview.superview.superview;
    UITableView *tableView = (UITableView *)cell.superview.superview;
//    NSLog(@"tag[%ld]", (long)tableView.tag);
    
    NSDictionary *addGameDict;
    if(tableView.tag == 0)
    {
//        NSIndexPath *indexPath = [self.hotGameTableView indexPathForCell:cell];
        addGameDict = hotGameArray[indexRow];
    }
    if(tableView.tag == 1)
    {
//        NSIndexPath *indexPath = [self.myGameTableView indexPathForCell:cell];
        addGameDict = myGameArray[indexRow];
    }
    
    [self addGameConfig:addGameDict];
}

-(void)addGameConfig:(NSDictionary *)addGameDict
{
    NSLog(@"开始游戏[%@]", addGameDict);
    
    //用户点击开始后，把这个游戏加入到他玩过的游戏中
    NSString *urlStr = ADD_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [addGameDict objectForKey:@"ContentPageID"]] forKey:@"GameId"];
    [request setDidFailSelector:@selector(addGameFail:)];
    [request setDidFinishSelector:@selector(addGameFinish:)];
    [request startAsynchronous];
    
    [self performSegueWithIdentifier:@"PushWebGame" sender:addGameDict];
}

- (void)addGameFinish:(ASIHTTPRequest *)req
{
    NSLog(@"addGameFinish");
//    [KKUtility justAlert:@"添加我玩过的游戏失败，请联系客服或重试。"];
}

- (void)addGameFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"添加我玩的游戏失败" :req.error];
}

//---------------------------------------更多----------------------------------------------//
- (void)checkMore:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ClassifyTableViewCell *cell = (ClassifyTableViewCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.classifyTableView indexPathForCell:cell];
    
    NSDictionary *classifyGameDict = classifyArray[indexPath.row];
    NSLog(@"点解更多,查看更多游戏[%@]", classifyGameDict);
    [self performSegueWithIdentifier:@"PushMoreGame" sender:classifyGameDict];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showGameDetail"])
    {
        NSDictionary *gameDict = (NSDictionary *)sender;
        GameDetailViewController *gdvc = (GameDetailViewController *)[segue destinationViewController];
        gdvc.gameDetailDict = gameDict;
    }
    
    if([segue.identifier isEqualToString:@"PushMoreGame"])
    {
        NSDictionary *classifyGameDict = (NSDictionary *)sender;
        MoreGameViewController *mgvc = (MoreGameViewController *)[segue destinationViewController];
        mgvc.moreGameDict = classifyGameDict;
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





























