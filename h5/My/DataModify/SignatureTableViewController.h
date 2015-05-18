//
//  SignatureTableViewController.h
//  ParkingLot
//
//  Created by wwj on 14/12/21.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureTableViewController : UITableViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *SignatureCell;
@property (weak, nonatomic) IBOutlet UITextView *signatureTextView;
@property (weak, nonatomic) IBOutlet UILabel *signatureMaxLabel;
@property (strong, nonatomic)NSString *signatureSegueString;
@property(strong, nonatomic)NSDictionary *userInfo;

@end
