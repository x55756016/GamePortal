//
//  MeDetailNameTableViewController.m
//  ooz
//
//  Created by wwj on 14-5-6.
//  Copyright (c) 2014年 wwj. All rights reserved.
//

#import "MeDetailNameTableViewController.h"

@interface MeDetailNameTableViewController ()
@end

@implementation MeDetailNameTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.nameTextField becomeFirstResponder];
}

//---------------------------------------------------------------------------------------------//
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.nameSegueString = textField.text;
    [self.MDNTVCdelegate meDetailNameTableViewControllerSave:self];
    return YES;
}

//---------------------------------------------------------------------------------------------//
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0)
    {
        cell = self.nameTableViewCell;
        self.nameTextField.text = _nameSegueString;
    }
    
    return cell;
}

- (IBAction)doCancle:(id)sender
{
    [self.MDNTVCdelegate meDetailNameTableViewControllerCancle:self];
}

- (IBAction)doSave:(id)sender
{
    self.nameSegueString = self.nameTextField.text;
    [self.MDNTVCdelegate meDetailNameTableViewControllerSave:self];
}

@end







