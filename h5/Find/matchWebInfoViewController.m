//
//  matchWebInfoViewController.m
//  ＋
//
//  Created by Administrator on 15/5/22.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "matchWebInfoViewController.h"

@interface matchWebInfoViewController ()

@end

@implementation matchWebInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.hidesBottomBarWhenPushed = YES;
    
    
    NSString *urlStr = [self.matchInfoDict objectForKey:@"Url"];
    NSLog(@"开始查看info[%@]", urlStr);
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
}

@end
