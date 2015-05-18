//
//  MeDetailCitiesTableViewController.m
//  ooz
//
//  Created by wwj on 14-5-12.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import "MeDetailCitiesTableViewController.h"
#import "DataModifyTableViewController.h"

UIKIT_EXTERN NSString *userFolderPath;

@interface MeDetailCitiesTableViewController ()
@end

@implementation MeDetailCitiesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.CitiesSegueArry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"citiesCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"citiesCell"];
    }
    
    cell.textLabel.text = [[self.CitiesSegueArry objectAtIndex:indexPath.row] objectForKey:@"city"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.userInfo setValue:self.StateSegue forKey:@"Province"];
    [self.userInfo setValue:[[self.CitiesSegueArry objectAtIndex:indexPath.row] objectForKey:@"city"] forKey:@"City"];
    
    NSUserDefaults *saveDefaults = [NSUserDefaults standardUserDefaults];
    NSString *UserInfoFolder = [[userFolderPath stringByAppendingPathComponent:[saveDefaults objectForKey:@"currentId"]] stringByAppendingPathComponent:@"UserInfo.plist"];
    if (![self.userInfo writeToFile:UserInfoFolder atomically:YES])
    {
        NSLog(@"保存用户信息失败");
    }
    
    for(UIViewController *vc in self.navigationController.viewControllers)
    {
        if([vc isKindOfClass:[DataModifyTableViewController class]])
        {
            DataModifyTableViewController *dmtvc = (DataModifyTableViewController *)vc;
            [self.navigationController popToViewController:dmtvc animated:YES];
        }
    }
}

@end




















