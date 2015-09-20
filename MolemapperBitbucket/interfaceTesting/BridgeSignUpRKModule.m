//
//  BridgeSignUpRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 8/21/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "BridgeSignUpRKModule.h"
#import "AppDelegate.h"
#import "BridgeManager.h"
#import <BridgeSDK/BridgeSDK.h>
#import "EmailVerifyViewController.h"

@implementation BridgeSignUpRKModule

//Create a very simple ResearchKit survey for user data entry for email and password
-(void)showSignUp
{
    NSMutableArray *signUpItems = [NSMutableArray new];
    ORKFormStep *signUpInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"signUp"
                                      title:@"Study Registration"
                                       text:@"We will send an email to the address below to confirm your registration in the research study."];
    
    
    ORKTextAnswerFormat *email = [ORKAnswerFormat textAnswerFormat];
    email.multipleLines = NO;
    email.spellCheckingType = UITextSpellCheckingTypeNo;
    email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    email.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [signUpItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"email"
                                                              text:@"Email"
                                                      answerFormat:email]];
    
    
    [signUpItems addObject:[[ORKFormItem alloc] initWithSectionTitle:@"Select your study login password"]];
    
    ORKTextAnswerFormat *password = [ORKAnswerFormat textAnswerFormat];
    password.multipleLines = NO;
    password.spellCheckingType = UITextSpellCheckingTypeNo;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [signUpItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"password"
                                                              text:@"Password"
                                                      answerFormat:password]];
    
    signUpInfo.formItems = signUpItems;
    
    ORKOrderedTask *task =
    [[ORKOrderedTask alloc] initWithIdentifier:@"signUpTask"
                                         steps:@[signUpInfo]];
    
    // Create a task view controller using the task and set a delegate.
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    
    // Present the task view controller.
    [self.presentingVC presentViewController:taskViewController animated:YES completion:nil];
}

-(void)taskViewController:(ORKTaskViewController * __nonnull)taskViewController
      didFinishWithReason:(ORKTaskViewControllerFinishReason)reason
                    error:(nullable NSError *)error
{
    ORKTaskResult *taskResult = [taskViewController result];
    
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            NSDictionary *parsedData = [self parsedDataFromTaskResult:taskResult];
            
            NSString *email = [parsedData valueForKey:@"email"];
            NSString *password = [parsedData valueForKey:@"password"];
            
            //In case of skip
            if (email.length == 0 || password.length == 0)
            {
                [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
                [self leaveOnboardingByCancelTapped];
                return;
            }
            
//Make a check here on whether or not the email and password are valid
//Protect against: length, has a lower and uppercase letter, at least one symbol
//Also segue to a screen that is the inbetween onboarding and mole map to give them the chance to go back
//Or just have a popup?
            
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            ad.user.bridgeSignInEmail = email;
            ad.user.bridgeSignInPassword = password;
            
            [SBBComponent(SBBAuthManager) signUpWithEmail: email
                                                 username: email
                                                 password: password
                                               completion: ^(NSURLSessionDataTask * __unused task,
                                                             id __unused responseObject,
                                                             NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(),^{
                     if (!error)
                     {
                         NSLog(@"User Signed Up");
                         EmailVerifyViewController *emailVerify = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"emailVerify"];
                         [self.presentingVC presentViewController:emailVerify animated:YES completion:nil];
                         
                     }
                     else
                     {
                         NSLog(@"error: %@",error);
                     }
                 });
             }];
            
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
            [self leaveOnboardingByCancelTapped];            break;
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
    
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"Go to Body Map" message:@"You can come back to the study enrollment process at any time by visiting the Profile tab" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Go to Body Map" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSLog(@"User has left the onboarding process with cancel");
        [ad showBodyMap];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self showSignUp];
    }];
    
    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self.presentingVC presentViewController:leaveOnboarding animated:YES completion:nil];
    
}

-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    
    NSString *email = @"";
    NSString *password = @"";
    
    NSArray *firstLevelResults = taskResult.results;
    for (ORKCollectionResult *firstLevel in firstLevelResults)
    {
        if ([firstLevel.identifier isEqualToString:@"signUp"])
        {
            NSLog(@"Processing SignUp here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"email"])
                {
                    if ([secondLevel isKindOfClass:[ORKTextQuestionResult class]])
                    {
                        ORKTextQuestionResult *textResult = (ORKTextQuestionResult *)secondLevel;
                        email = textResult.textAnswer;
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"password"])
                {
                    if ([secondLevel isKindOfClass:[ORKTextQuestionResult class]])
                    {
                        ORKTextQuestionResult *textResult = (ORKTextQuestionResult *)secondLevel;
                        password = textResult.textAnswer;
                    }
                }
            }
            
        }
        
        else
        {
            NSLog(@"Unknown task with identifier: %@",firstLevel.identifier);
        }
    }
    
    [parsedData setValue:email forKey:@"email"];
    [parsedData setValue:password forKey:@"password"];
    
    return parsedData;
}



@end