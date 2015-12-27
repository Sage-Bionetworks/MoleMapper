//
//  IntroAndEligibleRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
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


#import "IntroAndEligibleRKModule.h"
#import "AppDelegate.h"
#import "OnboardingViewController.h"

@interface IntroAndEligibleRKModule()

@property (strong,nonatomic) NSString *aboutStudyDetails;
@property (strong,nonatomic) ORKConsentDocument *consentDocument;

@end

@implementation IntroAndEligibleRKModule

-(ORKConsentDocument *)consentDocument
{
    if (!_consentDocument)
    {
        _consentDocument = [ORKConsentDocument new];
    }
    return _consentDocument;
}

-(void)showIntro
{
    ORKOrderedTask *introAndEligibleTask = nil;
    
    ORKInstructionStep *intro = [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
    intro.title = @"Welcome to\nMole Mapper!";
    intro.text = @"\nThis app is a personalized tool that helps you track your moles over time and participate in a research study to better understand skin health and melanoma risks";
    
    intro.image = [UIImage imageNamed:@"moleMapperIconLarge"];
    
    ORKInstructionStep *help = [[ORKInstructionStep alloc] initWithIdentifier:@"help"];
    help.title = @"Would you like to help our research?";
    help.text = @"\nTap “Get Started” to learn about this iPhone-based research study run by OHSU and Sage Bionetworks or tap “Cancel” to begin mapping";
    help.image = [UIImage imageNamed:@"ohsuSageLogos"];
    
    
    ORKConsentSection *overview =
    [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOverview];
    overview.title = @"What is involved";
    overview.summary = @"To join this study, we will ask you to:\n\n1. Consent to participating\n\n2. Register with your email address\n\n3. Answer questions about yourself\n\n4. Take pictures and measurements of your moles over time and share your mole data with the study team\n";
    overview.content = self.aboutStudyDetails;
    overview.customImage = [UIImage imageNamed:@"researchKit"];
    
    self.consentDocument.sections = @[overview];
    ORKVisualConsentStep *visualConsentStep =
    [[ORKVisualConsentStep alloc] initWithIdentifier:@"visualConsent" document:self.consentDocument];
    
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
    
    introAndEligibleTask = [[ORKOrderedTask alloc] initWithIdentifier:@"introAndEligible"
                                                                steps:@[intro,
                                                                        help,
                                                                        visualConsentStep,                                                                        eligibilityForm]];
    
    ORKTaskViewController *taskViewController =
    [[ORKTaskViewController alloc] initWithTask:introAndEligibleTask taskRunUUID:nil];
    taskViewController.delegate = self;
    taskViewController.showsProgressInNavigationBar = NO;
    [self.presentingVC presentViewController:taskViewController animated:YES completion:nil];

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
            [ud setBool:NO forKey:@"shouldShowIntroAndEligible"];
            
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
            [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
            [self leaveOnboardingByCancelTapped];
            break;
        }
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
            [self leaveOnboardingByCancelTapped];
            break;
        }
            
        case ORKTaskViewControllerFinishReasonSaved:
        {
            [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
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
        [self showIntro];
    }];

    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self.presentingVC presentViewController:leaveOnboarding animated:YES completion:nil];

}
    
#pragma mark - Learn more text

-(NSString *)aboutStudyDetails
{
    return @"Researchers from Sage Bionetworks (nonprofit) and OHSU Knight Cancer Institute invite you to participate in a research study about melanoma using Mole Mapper and Apple ResearchKit.\n\nThe aim of this study is to better understand skin biology and melanoma risks.\n\nBy analyzing the data from many Mole Mapper users we hope to better understand the variation in mole growth and cancer risks, and whether a mobile device can help people measure moles accurately and manage their skin health better.\n\nBy answering few questions about yourself, tracking your moles regularly and sharing your mole measurements you can help us learn how melanoma develops and what can be done to reduce risks of melanoma.\n\nIf you are over 18 years old, we invite you to join the study and declare war on melanoma.\n\nQuestions?  Please contact the study sponsor at +1 206-667-2115 or by email molemapperstudy@sagebase.org\n\nMole Mapper is a research study and does not provide medical advice, diagnosis or treatment\n\n";
}

@end
