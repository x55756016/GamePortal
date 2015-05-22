//
//  matchWebInfoViewController.h
//  ＋
//
//  Created by Administrator on 15/5/22.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface matchWebInfoViewController : UIViewController

@property (strong, nonatomic)NSDictionary *matchInfoDict;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
