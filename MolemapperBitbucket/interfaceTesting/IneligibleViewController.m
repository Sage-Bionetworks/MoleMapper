//
//  IneligibleViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "IneligibleViewController.h"
#import "AppDelegate.h"

@interface IneligibleViewController ()

@end

@implementation IneligibleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    // Do any additional setup after loading the view.
}

- (IBAction)startMappingButtonTapped:(id)sender
{
    //Go back and re-set the root view controller into the BodyMap storyboard 
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showBodyMap];
}
@end
