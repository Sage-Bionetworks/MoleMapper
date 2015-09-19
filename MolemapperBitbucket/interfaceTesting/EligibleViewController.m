//
//  EligibleViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "EligibleViewController.h"
#import "AppDelegate.h"

@interface EligibleViewController ()

@end

@implementation EligibleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];


    // Do any additional setup after loading the view.
}


- (IBAction)startConsentButtonTapped:(id)sender
{
    //Set up the flags that the onboarding VC will use to launch consent and NOT intro
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:@"shouldShowInfoScreens"];
    [ud setBool:NO forKey:@"shouldShowIntroAndEligible"];
    
    //Launch onboarding as root VC again, will draw from environment variables to determine which VC to load
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding];
}

@end
