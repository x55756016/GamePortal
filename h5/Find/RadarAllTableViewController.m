//
//  RadarAllTableViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "RadarAllTableViewController.h"
#import "AroundTableViewCell.h"
#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import "h5kkContants.h"
#import "UserInfoTableViewController.h"
#import "AppDelegate.h"
#import "CurrentUser.h"
#import "KKUtility.h"

@interface RadarAllTableViewController ()

@end

@implementation RadarAllTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //过滤分割线
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    footLabel.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)domissAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.radAllUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"aroundCells";
    [tableView registerNib:[UINib nibWithNibName:@"AroundTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    AroundTableViewCell *aroundTableViewCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *friendsDict = self.radAllUsers[indexPath.row];
    aroundTableViewCell.nickNameLabel.text = [friendsDict objectForKey:@"NickName"];
    aroundTableViewCell.signLabel.text = [friendsDict objectForKey:@"Sign"];

//    AppDelegate *kkAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    NSString *dintinc=[KKUtility getUserDistinctFromMyPoint:friendsDict :kkAppDelegate.currentlogingUser];
    
    NSNumber *dis=[friendsDict objectForKey:@"dis"];
    NSString *strDis= [NSString stringWithFormat:@"%d%@",[dis intValue],@"米"];
    aroundTableViewCell.disLabel.text =strDis;
    
    NSString *HeadIMGstring = [friendsDict objectForKey:@"PicPath"];
    HeadIMGstring = [HeadIMGstring stringByReplacingOccurrencesOfString:@".jpeg" withString:@"_b.jpeg"];
    [aroundTableViewCell.headImageView sd_setImageWithURL:[NSURL URLWithString:HeadIMGstring] placeholderImage:[UIImage imageNamed:@"userDefaultHead"]];
    return aroundTableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *playerDict = self.radAllUsers[indexPath.row];
    [self performSegueWithIdentifier:@"PushUserInfo" sender:playerDict];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushUserInfo"])
    {
        UserInfoTableViewController *uitvc = (UserInfoTableViewController *)[segue destinationViewController];
        uitvc.FriendInfoDict = (NSDictionary *)sender;
    }
}

@end























