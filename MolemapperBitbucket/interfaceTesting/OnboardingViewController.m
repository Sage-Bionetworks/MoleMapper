//
//  OnboardingViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "OnboardingViewController.h"
#import "IntroAndEligibleRKModule.h"
#import "AppDelegate.h"
#import "EligibleViewController.h"
#import "IneligibleViewController.h"
#import "ConsentRKModule.h"
#import "BridgeSignUpRKModule.h"
#import "QuizQuestionViewController.h"
#import "InitialSurveyRKModule.h"
#import "InfoScreensRKModule.h"
#import "EligibilityTestRKModule.h"

@interface OnboardingViewController ()

//@property (nonatomic, strong) IntroAndEligibleRKModule *introAndEligible;
@property (nonatomic, strong) EligibilityTestRKModule *eligibilityTest;
@property (nonatomic, strong) InfoScreensRKModule *infoScreens;
@property (nonatomic, strong) ConsentRKModule *consent;
@property (nonatomic, strong) BridgeSignUpRKModule *bridgeSignUp;
@property (nonatomic, strong) InitialSurveyRKModule *initialSurvey;

@end

@implementation OnboardingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //When you get through a given Module, turn off the shouldShow in UserDefaults so a user doesn't have to see redundant data
    //Enable a complete reset (or complete disable) from the settings
    
    /*if ([self shouldShowIntroAndEligible])
    {
        self.introAndEligible = [[IntroAndEligibleRKModule alloc] init];
        self.introAndEligible.presentingVC = self;
        [self.introAndEligible showIntro];
    }
     */
    
    if ([self shouldShowEligibilityTest])
    {
        self.eligibilityTest = [[EligibilityTestRKModule alloc] init];
        self.eligibilityTest.presentingVC = self;
        [self.eligibilityTest showEligibilityTest];
    }
    
    else if ([self shouldShowInfoScreens])
    {
        self.infoScreens = [[InfoScreensRKModule alloc] init];
        self.infoScreens.presentingVC = self;
        [self.infoScreens showInfoScreens];
    }
    
    else if ([self shouldShowQuiz])
    {
        [self showQuiz];
    }
    
    else if ([self shouldShowConsent])
    {
        self.consent = [[ConsentRKModule alloc] init];
        self.consent.presentingVC = self;
        [self.consent showConsent];
    }
    
    else if ([self shouldShowBridgeSignUp])
    {
        self.bridgeSignUp = [[BridgeSignUpRKModule alloc] init];
        self.bridgeSignUp.presentingVC = self;
        [self.bridgeSignUp showSignUp];
    }
  
    else if ([self shouldShowInitialSurvey])
    {
        self.initialSurvey = [[InitialSurveyRKModule alloc] init];
        self.initialSurvey.presentingVC = self;
        [self.initialSurvey showInitialSurvey];
    }
    
    else  //DEFAULT CASE HERE IS TO SWITCH TO BODYMAP VIEW
    {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ad showBodyMap];
    }
    
}

/*
-(BOOL)shouldShowIntroAndEligible
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL result = [ud boolForKey:@"shouldShowIntroAndEligible"];
    return result;
}
 */

-(BOOL)shouldShowEligibilityTest
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL result = [ud boolForKey:@"shouldShowEligibilityTest"];
    return result;
}

-(BOOL)shouldShowInfoScreens
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldShowInfoScreens"];
}

-(BOOL)shouldShowQuiz
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldShowQuiz"];
}

-(BOOL)shouldShowConsent
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldShowConsent"];
}

-(BOOL)shouldShowBridgeSignUp
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldShowBridgeSignup"];
}

-(BOOL)shouldShowInitialSurvey
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud boolForKey:@"shouldShowInitialSurvey"];
}

//Rather than launching from onboardingVC -- like with the ResearchKit modules-- set ineligible as rootVC
-(void)showIneligibleForStudy
{
    IneligibleViewController *ineligible = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil]
                                            instantiateViewControllerWithIdentifier:@"ineligible"];
    [self setUpRootViewController:ineligible];
}

-(void)showEligibleForStudy
{
    EligibleViewController *eligible = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil]
                                          instantiateViewControllerWithIdentifier:@"eligible"];
    [self setUpRootViewController:eligible];
}

-(void)showQuiz
{
    QuizQuestionViewController *quiz = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil]
                                        instantiateViewControllerWithIdentifier:@"quiz"];
    [self setUpRootViewController:quiz];
}

- (void) setUpRootViewController: (UIViewController*) viewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBar.translucent = NO;
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [UIView transitionWithView:ad.window
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        ad.window.rootViewController = navController;
                    }
                    completion:nil];
}


@end
