//
//  EligibilityTestRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 10/4/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "EligibilityTestRKModule.h"
#import "AppDelegate.h"
#import "OnboardingViewController.h"

@implementation EligibilityTestRKModule

-(void)showEligibilityTest
{
    ORKOrderedTask *eligibleTask = nil;
    
    NSMutableArray *eligibilityItems = [NSMutableArray new];
    ORKFormStep *eligibilityForm =
    [[ORKFormStep alloc] initWithIdentifier:@"eligibility"
                                      title:@"Study Eligibility"
                                       text:@"This study is designed for people at least 18 years old who are comfortable using an iPhone and the iPhone camera"];
    
    ORKAnswerFormat *age = [ORKAnswerFormat booleanAnswerFormat];
    [eligibilityItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"age"
                                                                   text:@"Are you 18 or older?"
                                                           answerFormat:age]];
    
    eligibilityForm.formItems = eligibilityItems;
    eligibilityForm.optional = NO;
    
    eligibleTask = [[ORKOrderedTask alloc] initWithIdentifier:@"eligible"
                                                                steps:@[eligibilityForm]];
    
    ORKTaskViewController *taskViewController =
    [[ORKTaskViewController alloc] initWithTask:eligibleTask taskRunUUID:nil];
    taskViewController.delegate = self;
    taskViewController.showsProgressInNavigationBar = NO;
    
    [self.presentingVC presentViewController:taskViewController animated:YES completion:^(){
    }];
    
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    
    /* Keeping solution from here (https://github.com/ResearchKit/ResearchKit/issues/328) as reference
    if ([stepViewController.step.identifier isEqualToString: @"qid_001"]) {
     
         Example of customizing the back and cancel buttons in a way that's
         visibly obvious.
     
        stepViewController.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back1"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:stepViewController.backButtonItem.target
                                                                            action:stepViewController.backButtonItem.action];
        stepViewController.cancelButtonItem = nil;
    }
    */
    stepViewController.cancelButtonItem = nil;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController
       didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                     error:(NSError *)error
{
    
    ORKTaskResult *taskResult = [taskViewController result];
    
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            
            //You have gotten through the eligibility question, so this doesn't get shown again
            //unless there is a reset
            [ud setBool:NO forKey:@"shouldShowWelcomeScreenWithCarousel"];
            [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
            [ud setBool:YES forKey:@"shouldShowInfoScreens"];
            
            NSNumber *age;
            
            NSArray *firstLevelResults = taskResult.results;
            for (ORKCollectionResult *firstLevel in firstLevelResults)
            {
                if ([firstLevel.identifier isEqualToString:@"intro"])
                {
                    NSLog(@"Processing intro here");
                    continue;
                }
                else if ([firstLevel.identifier isEqualToString:@"eligibility"])
                {
                    NSLog(@"Processing eligibility here");
                    for (ORKStepResult *secondLevel in firstLevel.results)
                    {
                        if ([secondLevel.identifier isEqualToString:@"age"])
                        {
                            if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                            {
                                ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                                NSNumber *booleanAnswer = booleanResult.booleanAnswer;
                                age = booleanAnswer;
                            }
                        }
                    }
                }
            }
            
            OnboardingViewController *onboarding = (OnboardingViewController *)self.presentingVC;
            if ([age isEqual:@1])
            {
                [onboarding showEligibleForStudy];
            }
            else
            {
                [onboarding showIneligibleForStudy];
            }
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
        case ORKTaskViewControllerFinishReasonFailed:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setBool:YES forKey:@"shouldShowWelcomeScreenWithCarousel"];
            [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            [self leaveOnboardingByCancelTapped];
            break;
        }
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setBool:YES forKey:@"shouldShowWelcomeScreenWithCarousel"];
            [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            [self leaveOnboardingByCancelTapped];
            break;
        }
            
        case ORKTaskViewControllerFinishReasonSaved:
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setBool:YES forKey:@"shouldShowWelcomeScreenWithCarousel"];
            [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            [self leaveOnboardingByCancelTapped];
            break;
        }
            
    }
    
    // Then, dismiss the task view controller.
    //[self.presentingVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)leaveOnboardingByCancelTapped
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"Go to Body Map" message:@"You can come back to the study enrollment process at any time by tapping the Beaker icon at the top of the Body Map. Your progress has been saved." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Go to Body Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"User has left the onboarding process with cancel");
        [ad showBodyMap];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [ad showWelcomeScreenWithCarousel];
    }];
    
    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self.presentingVC presentViewController:leaveOnboarding animated:YES completion:nil];
    
}


@end
