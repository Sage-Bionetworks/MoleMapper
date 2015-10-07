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
    introStep.text = @"We would like to ask you about the results of your mole removal. If you do not have the results from your doctor yet, you can return at any time by tapping the icon highlighted below.";
    
    introStep.image = [UIImage imageNamed:@"moleRemovedDemo"];
    
    
    ORKTextChoice *benign = [ORKTextChoice choiceWithText:@"No" detailText:@"No additional surgery was needed after my mole biopsy" value:@"benign" exclusive:YES];
    ORKTextChoice *reExcision = [ORKTextChoice choiceWithText:@"Yes" detailText:@"Additional surgery was needed to remove a larger area around the mole" value:@"reExcision" exclusive:YES];
    ORKTextChoice *unknown = [ORKTextChoice choiceWithText:@"Unknown" detailText:@"The results from this mole biopsy are not back yet" value:@"unknown" exclusive:YES];
    
    NSArray *diagnosisChoices = @[benign,reExcision,unknown];
    
    ORKTextChoiceAnswerFormat *diagnosis = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:diagnosisChoices];
    
    ORKQuestionStep *diagnosisStep = [ORKQuestionStep questionStepWithIdentifier:@"diagnosis"
                                                                            title:@"Did you need to have any additional surgery after your mole was removed?"
                                                                           answer:diagnosis];
    ORKInstructionStep *sitePhotoStep = [[ORKInstructionStep alloc] initWithIdentifier:@"sitePhoto"];
    sitePhotoStep.title = @"Biopsy Site Photo";
    sitePhotoStep.text = @"When it is safe to do so without a bandage, please measure the area where the mole was removed in the same way you would measure your mole.\n\nThis will help us understand the results of your procedure.";
    sitePhotoStep.image = [UIImage imageNamed:@"photoOfScar"];
    
    ORKInstructionStep *thankYouStep = [[ORKInstructionStep alloc] initWithIdentifier:@"thankYou"];
    thankYouStep.title = @"Thank you";
    thankYouStep.text = @"\nThe data you are contributing to this research will help us to understand and prevent skin cancer";
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[introStep,diagnosisStep,sitePhotoStep,thankYouStep]];
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
            //Structure of internal data for removedMolesToDiagnoses
            // "moleID" -> (NSNumber *)moleID,
            // "diagnoses -> (NSArray *)[array of diagnoses (NSStrings)]

            NSDictionary *parsedData = [self parsedDataFromTaskResult:taskResult];
            NSNumber *moleID = self.removedMole.moleID;
            NSArray *diagnosis = parsedData[@"diagnosis"];
            NSDictionary *removedMoleRecord = @{@"moleID" : moleID,
                                                @"diagnoses" : diagnosis};
            
            AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSMutableArray *removedMolesToDiagnoses = [ad.user.removedMolesToDiagnoses mutableCopy];
            for (int i = 0; i < removedMolesToDiagnoses.count; i++)
            {
                //Remove old record that has no diagnosis information in it
                NSDictionary *record = removedMolesToDiagnoses[i];
                if ([record objectForKey:@"moleID"] == moleID)
                {
                    [removedMolesToDiagnoses replaceObjectAtIndex:i withObject:removedMoleRecord];
                }
            }
            
            //Store updated set of records in user object
            ad.user.removedMolesToDiagnoses = removedMolesToDiagnoses;
            
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
    NSArray *diagnosis = @[];
    
        NSArray *firstLevelResults = taskResult.results;
        for (ORKCollectionResult *firstLevel in firstLevelResults)
        {
            if ([firstLevel.identifier isEqualToString:@"intro"])
            {
                NSLog(@"Processing intro here");
                continue;
            }
            else if ([firstLevel.identifier isEqualToString:@"diagnosis"])
            {
                NSLog(@"Processing diagnosis here");
                for (ORKStepResult *secondLevel in firstLevel.results)
                {
                    if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                    {
                        ORKChoiceQuestionResult *diagnosisResult = (ORKChoiceQuestionResult *)secondLevel;
                        diagnosis = diagnosisResult.choiceAnswers;
                    }
                }
            }
        }
    
    [parsedData setObject:diagnosis forKey:@"diagnosis"];
    
    return parsedData;
}

@end
