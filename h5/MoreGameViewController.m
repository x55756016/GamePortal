//
//  MoreGameViewController.m
//  h5
//
//  Created by hf on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "MoreGameViewController.h"
#import "GameTableViewCell.h"
#import "Reachability.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "GameDetailViewController.h"
#import "MJRefresh.h"
#import "GameWebViewController.h"
#import "h5kkContants.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface MoreGameViewController ()
{
    NSDictionary *userInfo;
    
    NSMutableArray *typeGameArray;
    int typeGamePageIndex;
}
@end

@implementation MoreGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    typeGamePageIndex = 1;
    
    //获取用户信息
    [self getUserInfo];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;
    
    //上下拉加载
    [self UpAndDownPull];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    }
}

//上下拉加载
-(void)UpAndDownPull
{
    //首次进来下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadTypeGame];
    }];
    [self.tableView.legendHeader beginRefreshing];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadTypeGameConfig];
    }];
}

//--------------------------------------------加载某个类型的游戏数据------------------------------------------//
-(void)loadTypeGame
{
    //下拉刷新永远请求第一页(PageIndex==1)的数据
    typeGamePageIndex = 1;
    [self loadTypeGameConfig];
}

-(void)loadTypeGameConfig
{
    NSString *urlStr = GET_GAME_LIST;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [self.moreGameDict objectForKey:@"CategoryID"]] forKey:@"iCategoryId"];
    [request setPostValue:[NSString stringWithFormat:@"%d", typeGamePageIndex] forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(loadTypeGameFail:)];
    [request setDidFinishSelector:@selector(loadTypeGameFinish:)];
    [request startAsynchronous];
}

- (void)loadTypeGameFinish:(ASIHTTPRequest *)request
{
//    NSLog(@"loadTypeGameFinish");
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    
    if([[dic objectForKey:@"IsSuccess"] integerValue])
    {
        [self loadTypeGameData:dic];
    }
    else
    {
        NSString *msgStr = [dic objectForKey:@"Msg"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取失败"
                                                        message:msgStr
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    //结束刷新状态
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

- (void)loadTypeGameFail:(ASIHTTPRequest *)request
{
//    NSLog(@"loadTypeGameFail");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络不好"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
    //结束刷新状态
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

//热门游戏数据刷表
-(void)loadTypeGameData:(NSDictionary *)dic
{
    NSMutableArray *newArray = [dic objectForKey:@"ObjData"];
    
    if(typeGamePageIndex > 1)
    {
        if(typeGameArray == nil)
        {
            typeGameArray = newArray;
        }
        else
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObjectsFromArray:typeGameArray];
            [tempArray addObjectsFromArray:newArray];
            typeGameArray = tempArray;
        }
        typeGamePageIndex += 1;
    }
    else
    {
        typeGameArray = newArray;
        if(typeGameArray.count >= 20)
        {
            typeGamePageIndex += 1;
        }
    }
    NSLog(@"加载typeGame[%lu]PageIndex[%d]", (unsigned long)typeGameArray.count, typeGamePageIndex);
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return typeGameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"gameCells";
    [tableView registerNib:[UINib nibWithNibName:@"GameTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *typeGameDict = typeGameArray[indexPath.row];
//    NSLog(@"typeGameDict[%@]", typeGameDict);
    cell.gameNameLabel.text = [typeGameDict objectForKey:@"Title"];
    cell.gameDesLabel.text = [typeGameDict objectForKey:@"Summary"];
    [cell.playGameBtn addTarget:self action:@selector(playGame:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *HeadIMGstring = [typeGameDict objectForKey:@"Logo"];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *typeGameDict = typeGameArray[indexPath.row];
    NSLog(@"各类游戏详情[%@]", typeGameDict);
    [self performSegueWithIdentifier:@"PushGameDetail" sender:typeGameDict];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

//---------------------------------------开始游戏----------------------------------------------//
- (void)playGame:(id)sender
{
    UIButton *button = (UIButton *)sender;
    GameTableViewCell *cell = (GameTableViewCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    NSLog(@"开始[%ld]", (long)indexPath.row);
    
    NSDictionary *addGameDict = typeGameArray[indexPath.row];
    [self addGameConfig:addGameDict];
}

-(void)addGameConfig:(NSDictionary *)addGameDict
{
    NSLog(@"开始游戏[%@]", addGameDict);
    
    //用户点击开始后，把这个游戏加入到他玩过的游戏中
    NSString *urlStr = ADD_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
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

- (void)addGameFinish:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFinish");
//    NSError *error;
//    NSData *responseData = [request responseData];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"addGamedir[%@]",dic);
}

- (void)addGameFail:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFail");
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushGameDetail"])
    {
        NSDictionary *gameDict = (NSDictionary *)sender;
        GameDetailViewController *gdvc = (GameDetailViewController *)[segue destinationViewController];
        gdvc.gameDetailDict = gameDict;
    }
    
    if([segue.identifier isEqualToString:@"PushWebGame"])
    {
        GameWebViewController *gwvc = (GameWebViewController *)[segue destinationViewController];
        gwvc.gameDetailDict = (NSDictionary *)sender;
    }
}

@end



















