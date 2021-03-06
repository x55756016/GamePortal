//
//  SearchGamesViewController.m
//  h5
//
//  Created by wwj on 15/4/7.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SearchGamesViewController.h"
#import "GameDetailViewController.h"
#import "GameTableViewCell.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "KKUtility.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface SearchGamesViewController ()
{
    NSArray *searchArry;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
}
@end

@implementation SearchGamesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    //设置焦点
    [self.searchTextField becomeFirstResponder];
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableFooterView = footLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        return searchArry.count;
    }
    @catch (NSException *exception) {
        return  0;
    }
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *reuseIdentifier = @"gameCells";
    [tableView registerNib:[UINib nibWithNibName:@"GameTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    @try {
        if(searchArry.count>0){
            NSDictionary *searchDict = searchArry[indexPath.row];
            //    NSLog(@"searchDict[%@]", searchDict);
            cell.gameNameLabel.text = [searchDict objectForKey:@"Title"];
            cell.gameDesLabel.text = [searchDict objectForKey:@"Summary"];
            [cell.playGameBtn addTarget:self action:@selector(playGame:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *HeadIMGstring = [searchDict objectForKey:@"Logo"];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
        }
    }
    @catch (NSException *exception) {
        [KKUtility logSystemErrorMsg:exception.reason :nil];
    }
       return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *searchDict = searchArry[indexPath.row];
//    NSLog(@"搜索结果的游戏详情[%@]", searchDict);
//    [self performSegueWithIdentifier:@"PushGameDetail" sender:searchDict];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

//------------------------------------UITextFieldDelegate---------------------------------------------------------//
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchGames:textField];
    [textField resignFirstResponder];
    return YES;
}

//进行搜索
-(void)searchGames:(UITextField *)textField
{
    NSString *urlStr = GAME_SEARCH;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:textField.text forKey:@"strName"];
    [request setPostValue:@"1" forKey:@"iPageIndex"];
    [request setDidFailSelector:@selector(searchGamesFail:)];
    [request setDidFinishSelector:@selector(searchGamesFinish:)];
    [request startAsynchronous];
}

- (void)searchGamesFinish:(ASIHTTPRequest *)req
{
    NSLog(@"searchGamesFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"searchGamesdict[%@]",dict);
    
    [SVProgressHUD dismiss];
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        [self searchGamesData:dict];
    }
}

- (void)searchGamesFail:(ASIHTTPRequest *)req
{
    [SVProgressHUD dismiss];
    [KKUtility showHttpErrorMsg:@"查询游戏失败 " :req.error];
}

//好友数据刷表
-(void)searchGamesData:(NSDictionary *)dict
{
    searchArry = [dict objectForKey:@"ObjData"];
//    NSLog(@"[%lu]%@", (unsigned long)searchArry.count, searchArry);
    [self.searchTableView reloadData];
}

- (void)playGame:(id)sender
{
    UIButton *button = (UIButton *)sender;
    GameTableViewCell *cell = (GameTableViewCell *)button.superview.superview.superview;
//    UITableView *tableView = (UITableView *)cell.superview.superview;

//    GameTableViewCell *cell = (GameTableViewCell *)button.superview.superview;
    NSIndexPath *indexPath = [self.searchTableView indexPathForCell:cell];

    NSDictionary *addGameDict = searchArry[indexPath.row];
    ////    NSLog(@"[%@]", addGameDict);

    
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
    
    [self performSegueWithIdentifier:@"PushStartGame" sender:addGameDict];
}

- (void)addGameFinish:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFinish");
    //    NSError *error;
    //    NSData *responseData = [request responseData];
    //    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    //    NSLog(@"addGamedir[%@]",dic);
}

- (void)addGameFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"添加我玩过的游戏失败 " :req.error];
}

//------------------------------------------------segue----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushStartGame"])
    {
        NSDictionary *gameDict = (NSDictionary *)sender;
        GameDetailViewController *gdvc = (GameDetailViewController *)[segue destinationViewController];
        gdvc.gameDetailDict = gameDict;
    }
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}
@end
























