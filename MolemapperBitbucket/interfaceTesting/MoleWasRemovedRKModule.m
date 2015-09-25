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
    
    ORKTextChoice *diagnosisKeyword1 = [ORKTextChoice choiceWithText:@"Acral Melanoma" value:@"diagnosisKeyword1"];
    ORKTextChoice *diagnosisKeyword2 = [ORKTextChoice choiceWithText:@"Atypical Nevus" value:@"diagnosisKeyword2"];
    ORKTextChoice *diagnosisKeyword3 = [ORKTextChoice choiceWithText:@"Benign Nevus" value:@"diagnosisKeyword3"];
    ORKTextChoice *diagnosisKeyword4 = [ORKTextChoice choiceWithText:@"Blue Nevus" value:@"diagnosisKeyword4"];
    ORKTextChoice *diagnosisKeyword5 = [ORKTextChoice choiceWithText:@"Dysplastic Nevi" value:@"diagnosisKeyword5"];
    ORKTextChoice *diagnosisKeyword6 = [ORKTextChoice choiceWithText:@"Melanoma In Situ" value:@"diagnosisKeyword6"];
    ORKTextChoice *diagnosisKeyword7 = [ORKTextChoice choiceWithText:@"Metastatic Melanoma" value:@"diagnosisKeyword7"];
    ORKTextChoice *diagnosisKeyword8 = [ORKTextChoice choiceWithText:@"Spitz Nevus" value:@"diagnosisKeyword8"];
    ORKTextChoice *diagnosisKeyword9 = [ORKTextChoice choiceWithText:@"Superfical Spreading Melanoma" value:@"diagnosisKeyword9"];
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
