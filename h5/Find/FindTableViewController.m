//
//  FindTableViewController.m
//  h5
//
//  Created by hf on 15/4/24.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "FindTableViewController.h"

@interface FindTableViewController ()

@end

@implementation FindTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.customPresentAnimation = [CustomPresentAnimation new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//-------------------------------------UIViewControllerTransitioningDelegate----------------------------------------//
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.customPresentAnimation;
}

//------------------------------------------ Table view data source --------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    
    else if(section == 2)
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
            cell = self.kkTableViewCell;
        }
    }
    
    if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            cell = self.aroundTableViewCell;
        }
//        if(indexPath.row == 1)
//        {
//            cell = self.squareTableViewCell;
//        }
    }
    
    if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            cell = self.matchTableViewCell;
        }
//        if(indexPath.row == 1)
//        {
//            cell = self.kkBarTableViewCell;
//        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//------------------------------------------segue--------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PushRadar"])
    {
        RadarViewController *rvc = (RadarViewController *)[segue destinationViewController];
        rvc.transitioningDelegate = self;
        rvc.RVCdelegate = self;
    }
}

//------------------------------RadarViewControllerDelegate---------------------------------//
-(void) radarViewControllerDidClickedDismissButton:(RadarViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

















































