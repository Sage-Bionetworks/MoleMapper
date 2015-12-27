//
//  MoleWasRemovedRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/25/15.
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


#import "MoleWasRemovedRKModule.h"
#import "AppDelegate.h"

@implementation MoleWasRemovedRKModule

-(void)showMoleRemoved
{
    ORKOrderedTask *task = nil;
    
   
    /* Don't need intro any more because that will be handled directly after the followup survey
     Leaving out the survey question about diagnosis until next version and IRB approval.
     Note that the diagnoses parsing code is still intact, but will not be used. The data transfer
     will take place at the time of tapping the moleWasRemovedByDoctor button
     
    ORKInstructionStep *introStep =
    [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
    introStep.title = @"Mole Removal Followup";
    introStep.text = @"Please navigate to the the mole that was removed and tap the settings button to inform us which mole was removed.";
    
    introStep.image = [UIImage imageNamed:@"moleRemovedDemo"];
    
    ORKTextChoice *benign = [ORKTextChoice choiceWithText:@"No" detailText:@"No additional surgery was needed after my mole biopsy" value:@"benign" exclusive:YES];
    ORKTextChoice *reExcision = [ORKTextChoice choiceWithText:@"Yes" detailText:@"Additional surgery was needed to remove a larger area around the mole" value:@"reExcision" exclusive:YES];
    ORKTextChoice *unknown = [ORKTextChoice choiceWithText:@"Unknown" detailText:@"The results from this mole biopsy are not back yet" value:@"unknown" exclusive:YES];
    
    NSArray *diagnosisChoices = @[benign,reExcision,unknown];
    
    ORKTextChoiceAnswerFormat *diagnosis = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:diagnosisChoices];
    
    ORKQuestionStep *diagnosisStep = [ORKQuestionStep questionStepWithIdentifier:@"diagnosis"
                                                                            title:@"Did you need to have any additional surgery after your mole was removed?"
                                                                           answer:diagnosis];
     */
    
    ORKInstructionStep *sitePhotoStep = [[ORKInstructionStep alloc] initWithIdentifier:@"sitePhoto"];
    sitePhotoStep.title = @"Biopsy Site Photo";
    sitePhotoStep.text = @"When it is safe to do so without a bandage, please measure the area where the mole was removed in the same way you would measure your mole.\n\nThis will help us understand the results of your procedure.";
    sitePhotoStep.image = [UIImage imageNamed:@"photoOfScar"];
    
    ORKInstructionStep *thankYouStep = [[ORKInstructionStep alloc] initWithIdentifier:@"thankYou"];
    thankYouStep.title = @"Thank you";
    thankYouStep.text = @"\nThe data you are contributing to this research will help us to understand and prevent skin cancer.";
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[sitePhotoStep,thankYouStep]];
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
                        //ORKChoiceQuestionResult *diagnosisResult = (ORKChoiceQuestionResult *)secondLevel;
                        //diagnosis = diagnosisResult.choiceAnswers;
                    }
                }
            }
        }
    
    
    [parsedData setObject:diagnosis forKey:@"diagnosis"];
    
    return parsedData;
}

@end
