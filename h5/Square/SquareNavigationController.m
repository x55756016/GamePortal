//
//  SquareNavigationController.m
//  h5
//
//  Created by hf on 15/4/16.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "SquareNavigationController.h"

@interface SquareNavigationController ()

@end

@implementation SquareNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
    //传递入口2. self.topViewController=SquareTableViewController(home/index)
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
