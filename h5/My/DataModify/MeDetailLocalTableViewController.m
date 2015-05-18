//
//  MeDetailLocalTableViewController.m
//  ooz
//
//  Created by wwj on 14-5-11.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import "MeDetailLocalTableViewController.h"
#import "MeDetailCitiesTableViewController.h"

@interface MeDetailLocalTableViewController ()
@end

@implementation MeDetailLocalTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"plist"];
    self.Provinces = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Provinces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"localCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"localCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *Province = [self.Provinces objectAtIndex:indexPath.row];
    NSString *State = [Province objectForKey:@"State"];
    cell.textLabel.text = State;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.Cities = [[self.Provinces objectAtIndex:indexPath.row] objectForKey:@"Cities"];
    self.State = [[self.Provinces objectAtIndex:indexPath.row] objectForKey:@"State"];
    [self performSegueWithIdentifier:@"PushCities" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushCities"])
    {
        MeDetailCitiesTableViewController *mdctvc = (MeDetailCitiesTableViewController *)[segue destinationViewController];
        mdctvc.CitiesSegueArry = self.Cities;
        mdctvc.StateSegue = self.State;
        mdctvc.userInfo = self.userInfo;
    }
}

@end













