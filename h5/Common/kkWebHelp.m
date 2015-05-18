//
//  kkWebHelp.m
//  ＋
//
//  Created by Administrator on 15/5/18.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "kkWebHelp.h"
#import "ASIFormDataRequest.h"
#import "h5kkContants.h"

@implementation kkWebHelp




-(void)addMyGameToServer:(NSDictionary *)addGameDict:(NSDictionary*)userInfo
{
    NSLog(@"开始游戏[%@]", addGameDict);
    
    //用户点击开始后，把这个游戏加入到他玩过的游戏中
    NSString *urlStr = ADD_GAME;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:5.0];
    [request setDelegate:self.delegate];
    [request setRequestMethod:@"POST"];
    [request setPostValue:@"1.0" forKey:@"version"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserId"]] forKey:@"UserId"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"UserKey"]] forKey:@"UserKey"];
    [request setPostValue:[NSString stringWithFormat:@"%@", [addGameDict objectForKey:@"ContentPageID"]] forKey:@"GameId"];
    [request setDidFailSelector:@selector(addGameFail:)];
    [request setDidFinishSelector:@selector(addGameFinish:)];
    [request startAsynchronous];
    [self.delegate addGameConfigComplete:@"addMyGameToServer Finish!"];

}

- (void)addGameFinish:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFinish");
  }

- (void)addGameFail:(ASIHTTPRequest *)request
{
    NSLog(@"addGameFail");
}
@end
