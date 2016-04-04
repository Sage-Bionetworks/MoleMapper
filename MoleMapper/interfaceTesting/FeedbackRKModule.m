//
//  FeedbackRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 10/6/15.
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


#import "FeedbackRKModule.h"
#import "AppDelegate.h"
#import "PopupManager.h"

NSUInteger const kFeedbackMaxLength = 2000;

@implementation FeedbackRKModule

-(void)showFeedback
{
    NSMutableArray *feedbackItems = [NSMutableArray new];
    ORKFormStep *feedbackInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"feedbackFormStep"
                                      title:@"Feedback"
                                       text:@"Please help us make this app more useful to you and more powerful for physicians and scientists. Please provide us with anonymous feedback below."];
    feedbackInfo.optional = NO;
    
    ORKTextAnswerFormat *feedbackAnswerFormat = [ORKTextAnswerFormat textAnswerFormatWithMaximumLength:kFeedbackMaxLength];
    feedbackAnswerFormat.multipleLines = YES;
    feedbackAnswerFormat.spellCheckingType = UITextSpellCheckingTypeDefault;
    feedbackAnswerFormat.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    feedbackAnswerFormat.autocorrectionType = UITextAutocorrectionTypeDefault;
    
    //[feedbackItems addObject:[[ORKFormItem alloc] initWithSectionTitle:@"\n\n"]];
    
    [feedbackItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"feedbackItem"
                                                                text:@""
                                                        answerFormat:feedbackAnswerFormat]];
    
    feedbackInfo.formItems = feedbackItems;
    
    ORKOrderedTask *task =
    [[ORKOrderedTask alloc] initWithIdentifier:@"feedbackTask"
                                         steps:@[feedbackInfo]];
    
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
            
            
            //NSString *feedback = [parsedData valueForKey:@"feedback"];
            //Store this locally in a cache to send later if not connected?
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ad.bridgeManager signInAndSendFeedback:parsedData];
            
            break;
        }
            
        case ORKTaskViewControllerFinishReasonFailed:
        {
            break;
        }
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            break;
        }
        case ORKTaskViewControllerFinishReasonSaved:
        {
            break;
        }
    }
    
    // Then, dismiss the task view controller.
    NSString *text = @"Thank you for your help and feedback!";
    [[PopupManager sharedInstance] createPopupWithText:text andSize:24.0];
    
    [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
    
    [self.presentingVC.navigationController popViewControllerAnimated:YES];;
    
}

-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    
    NSString *feedback = @"";
    
    NSArray *firstLevelResults = taskResult.results;
    for (ORKCollectionResult *firstLevel in firstLevelResults)
    {
        if ([firstLevel.identifier isEqualToString:@"feedbackFormStep"])
        {
            NSLog(@"Processing feedback here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"feedbackItem"])
                {
                    if ([secondLevel isKindOfClass:[ORKTextQuestionResult class]])
                    {
                        ORKTextQuestionResult *textResult = (ORKTextQuestionResult *)secondLevel;
                        feedback = textResult.textAnswer;
                    }
                }
            }
        }
        
        else
        {
            NSLog(@"Unknown task with identifier: %@",firstLevel.identifier);
        }
    }
    
    [parsedData setValue:feedback forKey:@"feedback"];
    
    return parsedData;
}


@end
