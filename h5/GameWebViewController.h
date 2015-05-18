//
//  GameWebViewController.h
//  h5
//
//  Created by hf on 15/4/15.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEXCMyUIButton.h"
//科大讯飞sdk
#import "iflyMSC/IFlyRecognizerViewDelegate.h"
#import "WXApi.h"
#import "kkWebHelp.h"

//forward declare
@class IFlyRecognizerView;

@protocol sendMsgToWeChatViewDelegate <NSObject>
- (void) sendImageContent;
- (void) sendMusicContent;
- (void) sendVideoContent;
- (void) changeScene:(NSInteger)scene;
- (void) sendLinkContent;
@end


@interface GameWebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate,UITextFieldDelegate,IFlyRecognizerViewDelegate,WXApiDelegate,UIActionSheetDelegate,addGameConfigCompleteDelegate>
//带界面的听写识别对象
@property (nonatomic,strong) IFlyRecognizerView * iflyRecognizerView;
@property (nonatomic,weak)   UITextField         * textMsgField;

@property (strong, nonatomic)NSDictionary *gameDetailDict;
@property (strong, nonatomic) IBOutlet UIWebView *gameWebView;

@property (nonatomic, assign) id<sendMsgToWeChatViewDelegate> delegate;

- (IBAction)exitAction:(id)sender;

@end
