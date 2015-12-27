//
//  ResearchKitFollowupModule.m
//  MoleMapper
//
//  Created by Dan Webster on 7/7/15.
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


#import "FollowupSurveyRKModule.h"
#import "BodyMapViewController.h"
#import "DataExporter.h"
#import "AppDelegate.h"

@implementation FollowupSurveyRKModule

-(NSNumber *)numberOfDaysBetweenFollowups
{
    return @30;
}

-(BOOL)shouldShowFollowupSurvey
{
    //For debugging the followup, which would otherwise only take place every 30 days
    //return YES;
    
    BOOL shouldShowFollowupSurvey = NO;
    
    NSDate *now = [NSDate date];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *lastTimeAsurveyWasTaken = [ud valueForKey:@"dateOfLastSurveyCompleted"];
    
    NSNumber *daysSinceLastSurvey = [NSNumber numberWithInteger:[self daysBetweenDate:lastTimeAsurveyWasTaken andDate:now]];
    NSLog(@"It has been %@ days since the last survey was taken",daysSinceLastSurvey);
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (ad.user.hasEnrolled == NO)
    {
        return NO;
    }
    if ([daysSinceLastSurvey intValue] >= numberOfDaysInFollowupPeriod)
    {
        shouldShowFollowupSurvey = YES;
    }
    return shouldShowFollowupSurvey;
}

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

-(void)showSurvey
{
    ORKInstructionStep *intro = [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
    intro.title = @"Monthly Followup";
    intro.text = @"\nWe'd like to ask you 5 quick questions about your activities and health in the last month";
    
    intro.image = [UIImage imageNamed:@"sunIcon"];

    
    NSMutableArray *followupItems = [NSMutableArray new];
    ORKFormStep *followupInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"followupInfo"
                                      title:@""
                                       text:@""];
    
    ORKAnswerFormat *tan = [ORKAnswerFormat booleanAnswerFormat];
    [followupItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"tan"
                                                               text:@"In the past month, have you gotten a tan?"
                                                       answerFormat:tan]];
    ORKAnswerFormat *burn = [ORKAnswerFormat booleanAnswerFormat];
    [followupItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"burn"
                                                                text:@"In the past month, have you gotten sunburned?"
                                                        answerFormat:burn]];
    ORKAnswerFormat *sunscreen = [ORKAnswerFormat booleanAnswerFormat];
    [followupItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"sunscreen"
                                                                text:@"In the past month, have you used sunscreen?"
                                                        answerFormat:sunscreen]];
    ORKAnswerFormat *sick = [ORKAnswerFormat booleanAnswerFormat];
    [followupItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"sick"
                                                                text:@"In the past month, have you been sick enough to miss work or school?"
                                                        answerFormat:sick]];
    ORKAnswerFormat *removed = [ORKAnswerFormat booleanAnswerFormat];
    [followupItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"removed"
                                                                text:@"In the past month, have you had any moles removed?"
                                                        answerFormat:removed]];
    followupInfo.formItems = followupItems;
    
    ORKInstructionStep *thankYouStep = [[ORKInstructionStep alloc] initWithIdentifier:@"thankYou"];
    thankYouStep.title = @"Thank you!";
    thankYouStep.text = @"\nYour dedication to consistently mapping and measuring your moles every month is helping us to better understand skin cancer risk\n\nKeep up the great work\nand Happy Mapping!";
    
    ORKOrderedTask *task =
    [[ORKOrderedTask alloc] initWithIdentifier:@"followupTask"
                                         steps:@[intro, followupInfo, thankYouStep]];
    
    
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
            NSDate *dateOfLastSurveyCompleted = taskResult.endDate;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setValue:dateOfLastSurveyCompleted forKey:@"dateOfLastSurveyCompleted"];
            
            NSDictionary *parsedData = [self parsedDataFromTaskResult:taskResult];
            
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ad.bridgeManager signInAndSendFollowupData:parsedData];
            
            if ([[parsedData valueForKey:@"moleRemoved"]  isEqual: @1])
            {
                [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
                BodyMapViewController *bmvc = (BodyMapViewController *)self.presentingVC;
                bmvc.shouldShowMoleRemovedPopup = YES;
                break;
            }
            else
            {
                [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            
        }
            
        case ORKTaskViewControllerFinishReasonFailed:
        {
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
        case ORKTaskViewControllerFinishReasonSaved:
        {
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
    }
    
    // Then, dismiss the task view controller.
    //[self.presentingVC dismissViewControllerAnimated:YES completion:nil];
}

//Schema expected by Bridge for followup
/*
 followup
 followup.json.sunburn - int
 followup.json.moleRemoved - int
 followup.json.sunscreen - int
 followup.json.sick - int
 followup.json.tan - int
 followup.json.date - timestamp
*/
-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    
    //Use the date that the followup was completed, note that Bridge requires ISO8601 formatting
    NSString *date = @"";
    NSDate *endDate = taskResult.endDate;
    date = [self iso8601stringFromDate:endDate];
    [parsedData setValue:date forKey:@"date"];
    
    NSArray *firstLevelResults = taskResult.results;
    for (ORKCollectionResult *firstLevel in firstLevelResults)
    {
        if ([firstLevel.identifier isEqualToString:@"intro"])
        {
            NSLog(@"Processing intro here");
            continue;
        }
        else if ([firstLevel.identifier isEqualToString:@"followupInfo"])
        {
            for (ORKBooleanQuestionResult *questionResult in firstLevel.results)
            {
                NSString *label = questionResult.identifier;
                //1 for yes, 0 for no, BridgeServer schema is expecting an int here
                NSNumber *booleanValue = ([questionResult.booleanAnswer isEqual:@1]) ? @1 : @0;
        
                if ([label isEqualToString:@"tan"])             {[parsedData setValue:booleanValue forKey:@"tan"];}
                else if ([label isEqualToString:@"burn"])       {[parsedData setValue:booleanValue forKey:@"sunburn"];}
                else if ([label isEqualToString:@"sunscreen"])  {[parsedData setValue:booleanValue forKey:@"sunscreen"];}
                else if ([label isEqualToString:@"sick"])       {[parsedData setValue:booleanValue forKey:@"sick"];}
                else if ([label isEqualToString:@"removed"])    {[parsedData setValue:booleanValue forKey:@"moleRemoved"];}
                else {NSLog(@"in followup survey results, found an unexpected answer format identifier!: %@",label);}
            }
        }
    }
    return parsedData;
}

-(NSString *)iso8601stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *iso8601String = [dateFormatter stringFromDate:date];
    return iso8601String;
}


@end
