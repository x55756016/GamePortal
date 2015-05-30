//
//  HomeInfoViewController.h
//  ＋
//
//  Created by Administrator on 15/5/6.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeInfoViewController : UIViewController

@property (strong, nonatomic)NSDictionary *WebInfoDict;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
