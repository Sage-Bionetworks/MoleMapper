//
//  MoleWasRemovedRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/25/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "MoleWasRemovedRKModule.h"
#import "AppDelegate.h"

@implementation MoleWasRemovedRKModule

-(void)showMoleRemoved
{
    ORKOrderedTask *task = nil;
    
    ORKInstructionStep *introStep =
    [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
    introStep.title = @"Mole Removal Followup";
    introStep.text = @"We would like to ask you about the results of your mole removal. If you do not have a report from your doctor yet, you can return at any time by tapping the icon highlighted below.";
    
    introStep.image = [UIImage imageNamed:@"moleRemovedDemo"];
    
    ORKTextChoice *diagnosisKeyword1 = [ORKTextChoice choiceWithText:@"diagnosisKeyword1" value:@"diagnosisKeyword1"];
    ORKTextChoice *diagnosisKeyword2 = [ORKTextChoice choiceWithText:@"diagnosisKeyword2" value:@"diagnosisKeyword2"];
    ORKTextChoice *diagnosisKeyword3 = [ORKTextChoice choiceWithText:@"diagnosisKeyword3" value:@"diagnosisKeyword3"];
    ORKTextChoice *diagnosisKeyword4 = [ORKTextChoice choiceWithText:@"diagnosisKeyword4" value:@"diagnosisKeyword4"];
    ORKTextChoice *diagnosisKeyword5 = [ORKTextChoice choiceWithText:@"diagnosisKeyword5" value:@"diagnosisKeyword5"];
    ORKTextChoice *diagnosisKeyword6 = [ORKTextChoice choiceWithText:@"diagnosisKeyword6" value:@"diagnosisKeyword6"];
    ORKTextChoice *diagnosisKeyword7 = [ORKTextChoice choiceWithText:@"diagnosisKeyword7" value:@"diagnosisKeyword7"];
    ORKTextChoice *diagnosisKeyword8 = [ORKTextChoice choiceWithText:@"diagnosisKeyword8" value:@"diagnosisKeyword8"];
    ORKTextChoice *diagnosisKeyword9 = [ORKTextChoice choiceWithText:@"diagnosisKeyword9" value:@"diagnosisKeyword9"];
    ORKTextChoice *diagnosisKeyword10 = [ORKTextChoice choiceWithText:@"diagnosisKeyword10" value:@"diagnosisKeyword10"];
    ORKTextChoice *waiting = [ORKTextChoice choiceWithText:@"Waiting for Biopsy Report" value:@"waiting"];
    ORKTextChoice *none = [ORKTextChoice choiceWithText:@"None of the above choices" value:@"none"];
    
    NSArray *diagnosisChoices = @[diagnosisKeyword1,
                                  diagnosisKeyword2,
                                  diagnosisKeyword3,
                                  diagnosisKeyword4,
                                  diagnosisKeyword5,
                                  diagnosisKeyword6,
                                  diagnosisKeyword7,
                                  diagnosisKeyword8,
                                  diagnosisKeyword9,
                                  diagnosisKeyword10,
                                  waiting,
                                  none];
    
    ORKTextChoiceAnswerFormat *diagnosis = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:diagnosisChoices];
    //ORKValuePickerAnswerFormat *diagnosis =
    //[ORKValuePickerAnswerFormat valuePickerAnswerFormatWithTextChoices:diagnosisChoices];
    ORKQuestionStep *diagnosisStep = [ORKQuestionStep questionStepWithIdentifier:@"diagnosis"
                                                                            title:@"Please select any terms that appear in your biopsy report"
                                                                           answer:diagnosis];
    ORKInstructionStep *sitePhotoStep = [[ORKInstructionStep alloc] initWithIdentifier:@"sitePhoto"];
    sitePhotoStep.title = @"Biopsy Site Photo";
    sitePhotoStep.text = @"When it is safe to do so without a bandage, please measure the area where the mole was removed in the same way you would measure your mole.\n\nThis will help us understand the results of the procedure, and thank you for contributing to our research!";
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[introStep,diagnosisStep,sitePhotoStep]];
    ORKTaskViewController *taskViewController =
    [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;
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
            NSDictionary *parsedData = [self parsedDataFromTaskResult:taskResult];
            
            AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            //[ad.bridgeManager signInAndSendDiagnosisData:parsedData];
            
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
    
    [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
}

-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    NSString *diagnosis = @"";
    
        NSArray *firstLevelResults = taskResult.results;
        for (ORKCollectionResult *firstLevel in firstLevelResults)
        {
            if ([firstLevel.identifier isEqualToString:@"intro"])
            {
                NSLog(@"Processing intro here");
                continue;
            }
            else if ([firstLevel.identifier isEqualToString:@"profession"])
            {
                NSLog(@"Processing diagnosis here");
                for (ORKStepResult *secondLevel in firstLevel.results)
                {
                    if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                    {
                        ORKChoiceQuestionResult *diagnosisResult = (ORKChoiceQuestionResult *)secondLevel;
                        diagnosis = diagnosisResult.choiceAnswers[0];
                    }
                }
            }
        }
    
    
    return parsedData;
}

@end
