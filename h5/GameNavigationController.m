//
//  GameNavigationController.m
//  h5
//
//  Created by hf on 15/4/15.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "GameNavigationController.h"

@interface GameNavigationController ()

@end

@implementation GameNavigationController

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
}
-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
