//
//  FeedbackRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 10/6/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "FeedbackRKModule.h"
#import "AppDelegate.h"
#import "PopupManager.h"

@implementation FeedbackRKModule

-(void)showFeedback
{
    NSMutableArray *feedbackItems = [NSMutableArray new];
    ORKFormStep *feedbackInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"feedbackFormStep"
                                      title:@"Feedback"
                                       text:@"Our goal is to stop needless loss of life due to melanomas that can be detected early.\n\nThis app is only the first step, so help us to make it more useful to you and more powerful for physicians and scientists. Please provide us with anonymous feedback below"];
    feedbackInfo.optional = NO;
    
    ORKTextAnswerFormat *feedbackAnswerFormat = [ORKTextAnswerFormat textAnswerFormat];
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
