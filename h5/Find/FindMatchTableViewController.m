//
//  FindMatchTableViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "FindMatchTableViewController.h"
#import "MatchTableViewCell.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "KKUtility.h"
#import "matchWebInfoViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface FindMatchTableViewController ()
{
    NSArray *matchArray;
    NSDictionary *userInfo;
    ASIFormDataRequest *request;
}
@end

@implementation FindMatchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;

    //获取用户信息
     userInfo = [KKUtility getUserInfoFromLocalFile];
    //加载联赛数据
    [self loadMatch];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";    
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//加载联赛数据
- (void)loadMatch
{
    NSString *urlStr = GET_ACTIVE_LIST;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:10.0];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:@"1" forKey:@"pageindex"];
    [request setPostValue:@"0" forKey:@"pageType"];;
    [request setDidFailSelector:@selector(loadMatchFail:)];
    [request setDidFinishSelector:@selector(loadMatchFinish:)];
    [request startAsynchronous];
}

- (void)loadMatchFinish:(ASIHTTPRequest *)req
{
    NSLog(@"loadMatchFinish");
    NSError *error;
    NSData *responseData = [req responseData];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
//    NSLog(@"Matchdict[%@]", dict);
    
    if([[dict objectForKey:@"IsSuccess"] integerValue])
    {
        matchArray = [dict objectForKey:@"ObjData"];
//        NSLog(@"matchArray[%d][%@]", matchArray.count, matchArray);
    }
    [self.tableView reloadData];
}

- (void)loadMatchFail:(ASIHTTPRequest *)req
{
    [KKUtility showHttpErrorMsg:@"加载联赛数据失败 " :req.error];
    [self.tableView reloadData];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return matchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"matchCells";
    [tableView registerNib:[UINib nibWithNibName:@"MatchTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    MatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *matchDict = matchArray[indexPath.row];
    cell.matchNameLabel.text = [matchDict objectForKey:@"Title"];
    cell.matchDetailLabel.text = [matchDict objectForKey:@"Summary"];
    [cell.btnOpenActiveDetail addTarget:self action:@selector(OpenActiveDetail:) forControlEvents:UIControlEventTouchUpInside];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    NSArray *descImgArray = [[matchDict objectForKey:@"DescImg"] componentsSeparatedByString:@"||"];
    NSString *strUrl=[matchDict objectForKey:@"Logo"];
    [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"mainBoard_adLogoDefault"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *matchDict = matchArray[indexPath.row];
    NSString *strUrl=[NSString stringWithFormat:@"%@", [matchDict objectForKey:@"ContentPageID"]];
//
    NSString *strActive=[@"http://www.h5kk.com/KKActive/" stringByAppendingString:strUrl];
    strUrl =strActive;
//
    NSDictionary *adDic=[NSDictionary dictionaryWithObject:strUrl forKey:@"Url"];
//    NSLog(@"查看联赛排名详情[%@]", adDic);
    [self performSegueWithIdentifier:@"openMatchInfoWeb" sender:adDic];
    

}
- (IBAction)OpenActiveDetail:(id)sender
{
    @try {
        UIButton *button = (UIButton *)sender;
        MatchTableViewCell *cell = (MatchTableViewCell *)button.superview.superview.superview.superview;
       
        UITableView *tableView = (UITableView *)cell.superview;
        if (![tableView isKindOfClass:[UITableView class]])
        {
            tableView = (UITableView *)tableView.superview;
        }
        //    NSLog(@"tag[%ld]", (long)tableView.tag);
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        
        
        NSDictionary *matchDict = matchArray[indexPath.row];
        NSString *strUrl=[NSString stringWithFormat:@"%@", [matchDict objectForKey:@"ContentPageID"]];
        
        NSString *strActive=[@"http://www.h5kk.com/KKActive/" stringByAppendingString:strUrl];
        strUrl =strActive;
        
        NSDictionary *adDic=[NSDictionary dictionaryWithObject:strUrl forKey:@"Url"];
        NSLog(@"查看联赛排名详情[%@]", adDic);
        [self performSegueWithIdentifier:@"openMatchInfoWeb" sender:adDic];
    }
    @catch (NSException *exception) {
        
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"openMatchInfoWeb"])
    {
        matchWebInfoViewController *gwvc = (matchWebInfoViewController *)[segue destinationViewController];
        gwvc.matchInfoDict = (NSDictionary *)sender;
    }
}

- (void)dealloc
{
    [request setDelegate:nil];
    [request cancel];
}

@end

























