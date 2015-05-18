//
//  MeDetailAgeTableViewController.m
//  h5
//
//  Created by hf on 15/4/3.
//  Copyright (c) 2015年 hf. All rights reserved.
//

#import "MeDetailAgeTableViewController.h"

@interface MeDetailAgeTableViewController ()

@end

@implementation MeDetailAgeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.ageTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//---------------------------------------------------------------------------------------------//
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.ageSegueString = textField.text;
    [self.MDATVCdelegate meDetailAgeTableViewControllerSave:self];
    return YES;
}

//---------------------------------------------------------------------------------------------//
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
        cell = self.ageTableViewCell;
        self.ageTextField.text = _ageSegueString;
    }
    
    return cell;
}

- (IBAction)doCancle:(id)sender
{
    [self.MDATVCdelegate meDetailAgeTableViewControllerCancle:self];
}

- (IBAction)doSave:(id)sender
{
    self.ageSegueString = self.ageTextField.text;
    [self.MDATVCdelegate meDetailAgeTableViewControllerSave:self];
}

@end




















