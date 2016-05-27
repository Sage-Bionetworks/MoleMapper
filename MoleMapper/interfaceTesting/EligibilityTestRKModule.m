//
//  EligibilityTestRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 10/4/15.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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
                                       text:@"This study is designed for people at least 18 years old who are comfortable using a smartphone camera"];
    
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
    
    //This is a way to get rid of the cancel button
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
            
            /*Independent of the answer to the eligibility questions, you have gotten through the eligibility question, so this doesn't get shown again unless there is a reset. Set up the onboarding flow booleans here so that you don't go backwards and see redundant content if you leave and come back.
             */
            
            [ud setBool:NO forKey:@"shouldShowWelcomeScreenWithCarousel"];
            [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
            
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
                [ud setBool:YES forKey:@"shouldShowOnboarding"];
                [ud setBool:YES forKey:@"shouldShowInfoScreens"];
                [onboarding showEligibleForStudy];
            }
            else
            {
                //Set onboarding to NO here so that you can't just re-enter through the beaker icon
                [ud setBool:NO forKey:@"shouldShowOnboarding"];
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
