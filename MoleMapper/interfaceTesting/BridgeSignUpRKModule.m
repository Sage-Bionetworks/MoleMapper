//
//  BridgeSignUpRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 8/21/15.
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
    
    
    [signUpItems addObject:[[ORKFormItem alloc] initWithSectionTitle:@"Create your study login password"]];
    
    ORKTextAnswerFormat *password = [ORKAnswerFormat textAnswerFormat];
    password.multipleLines = NO;
    password.spellCheckingType = UITextSpellCheckingTypeNo;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [signUpItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"password"
                                                              text:@"Password"
                                                      answerFormat:password]];
    
    signUpInfo.formItems = signUpItems;
    signUpInfo.optional = NO;
    
    ORKOrderedTask *task =
    [[ORKOrderedTask alloc] initWithIdentifier:@"signUpTask"
                                         steps:@[signUpInfo]];
    
    // Create a task view controller using the task and set a delegate.
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
    taskViewController.showsProgressInNavigationBar = NO;
    
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
            
            if ([self NSStringIsValidEmail:email] == NO || password.length < 6)
            {
                [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
                [self emailOrPasswordNotValid];
                break;
            }
            
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            ad.user.bridgeSignInEmail = email;
            ad.user.bridgeSignInPassword = password;
            [SBBComponent(SBBAuthManager) signUpWithEmail: email
                                                 username: email
                                                 password: password
                                               completion: ^(NSURLSessionDataTask * __unused task,
                                                             id __unused responseObject,
                                                             NSError *error) {
                 dispatch_async(dispatch_get_main_queue(),^{
                     if (!error)
                     {
                         NSLog(@"User is SIGNED UP");
                     }
                     else
                     {
                         NSLog(@"error: %@",error);
                     }
                 });
             }];
            
            [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
            EmailVerifyViewController *emailVerify = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"emailVerify"];
            [self.presentingVC presentViewController:emailVerify animated:YES completion:nil];
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
        [self showSignUp];
    }];
    
    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self.presentingVC presentViewController:leaveOnboarding animated:YES completion:nil];
}

-(void)emailOrPasswordNotValid
{
    UIAlertController *notValid = [UIAlertController alertControllerWithTitle:@"Invalid Email/Password" message:@"We detected an improperly formatted email address or a password shorter than 6 characters.  Please try with different information" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *reEnter = [UIAlertAction actionWithTitle:@"Re-enter Email/Password" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self showSignUp];
    }];
    
    [notValid addAction:reEnter];
    
    [self.presentingVC presentViewController:notValid animated:YES completion:nil];
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
