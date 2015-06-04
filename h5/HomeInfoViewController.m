//
//  HomeInfoViewController.m
//  ＋
//
//  Created by Administrator on 15/5/6.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "HomeInfoViewController.h"

@interface HomeInfoViewController ()

@end

@implementation HomeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
     self.hidesBottomBarWhenPushed = YES;
    
    
    NSString *urlStr = [self.WebInfoDict objectForKey:@"Url"];
    NSLog(@"开始查看info[%@]", urlStr);
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];  //设置状态栏初始状态
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.hidesBottomBarWhenPushed = NO;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
