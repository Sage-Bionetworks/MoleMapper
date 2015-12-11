//
//  ThankYouViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/23/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "ThankYouViewController.h"
#import "AppDelegate.h"

@interface ThankYouViewController ()

@end

@implementation ThankYouViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    // Do any additional setup after loading the view.
}

- (IBAction)startMappingButtonTapped:(id)sender
{
    //At this point, you are officially done with the onboarding process
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"shouldShowInitialSurvey"];
    [ud setBool:NO forKey:@"shouldShowOnboarding"];
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showBodyMap];
}

-(IBAction)answerQuestionsButtonTapped:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"shouldShowBridgeSignup"];
    [ud setBool:YES forKey:@"shouldShowInitialSurvey"];

    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding];
}

@end
