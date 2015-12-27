//
//  InitialSurveyRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 8/29/15.
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


#import "InitialSurveyRKModule.h"
#import "AppDelegate.h"

@implementation InitialSurveyRKModule

-(void)showInitialSurvey
{
    
    ORKOrderedTask *task = nil;
    
    ORKInstructionStep *introStep =
    [[ORKInstructionStep alloc] initWithIdentifier:@"intro"];
    introStep.title = @"About You";
    introStep.text = @"We'd like to ask you a few questions to better understand potential melanoma risk\n\nThese questions should take less than 5 minutes";
    
    NSMutableArray *basicInfoItems = [NSMutableArray new];
    ORKFormStep *basicInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"basicInfo"
                                      title:@"About You"
                                       text:@""];
    
    ORKAnswerFormat *dateOfBirthFormat =
    [ORKHealthKitCharacteristicTypeAnswerFormat
     answerFormatWithCharacteristicType:
     [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
    ORKFormItem *dateOfBirthItem =
    [[ORKFormItem alloc] initWithIdentifier:@"dateOfBirth"
                                       text:@"Date of Birth"
                               answerFormat:dateOfBirthFormat];
    dateOfBirthItem.placeholder = @"DOB";
    [basicInfoItems addObject:dateOfBirthItem];
    
    ORKAnswerFormat *genderFormat =
    [ORKHealthKitCharacteristicTypeAnswerFormat
     answerFormatWithCharacteristicType:
     [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
    [basicInfoItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"gender"
                                                                 text:@"Gender"
                                                         answerFormat:genderFormat]];
    
    ORKNumericAnswerFormat *zipCode =
    [ORKNumericAnswerFormat integerAnswerFormatWithUnit:nil];
    [basicInfoItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"zipCode"
                                                                 text:@"What is your zip code?"
                                                         answerFormat:zipCode]];
    
    basicInfo.formItems = basicInfoItems;
    
    NSMutableArray *hairEyesItems = [NSMutableArray new];
    ORKFormStep *hairEyesInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"hairEyesInfo"
                                      title:@"Natural Hair and Eye Color"
                                       text:@""];
    
    ORKTextChoice *redHair = [ORKTextChoice choiceWithText:@"Red Hair" value:@"redHair"];
    ORKTextChoice *blondeHair = [ORKTextChoice choiceWithText:@"Blonde Hair" value:@"blondeHair"];
    ORKTextChoice *brownHair = [ORKTextChoice choiceWithText:@"Brown Hair" value:@"brownHair"];
    ORKTextChoice *blackHair = [ORKTextChoice choiceWithText:@"Black Hair" value:@"blackHair"];
    NSArray *hairColorChoices = @[redHair,blondeHair,brownHair,blackHair];
    ORKValuePickerAnswerFormat *hairColor =
    [ORKValuePickerAnswerFormat valuePickerAnswerFormatWithTextChoices:hairColorChoices];
    [hairEyesItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"hairColor" text:@"Hair Color" answerFormat:hairColor]];
    
    ORKTextChoice *blueEyes = [ORKTextChoice choiceWithText:@"Blue Eyes" value:@"blueEyes"];
    ORKTextChoice *greenEyes = [ORKTextChoice choiceWithText:@"Green Eyes" value:@"greenEyes"];
    ORKTextChoice *brownEyes = [ORKTextChoice choiceWithText:@"Brown Eyes" value:@"brownEyes"];
    NSArray *eyeColorChoices = @[blueEyes,greenEyes,brownEyes];
    ORKValuePickerAnswerFormat *eyeColor =
    [ORKValuePickerAnswerFormat valuePickerAnswerFormatWithTextChoices:eyeColorChoices];
    [hairEyesItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"eyeColor" text:@"Eye Color" answerFormat:eyeColor]];
    
    hairEyesInfo.formItems = hairEyesItems;
    
    ORKTextChoice *pilot = [ORKTextChoice choiceWithText:@"Pilot or flight crew" value:@"pilot"];
    ORKTextChoice *dental = [ORKTextChoice choiceWithText:@"Dental professional" value:@"dental"];
    ORKTextChoice *construction = [ORKTextChoice choiceWithText:@"Construction" value:@"construction"];
    ORKTextChoice *radiology = [ORKTextChoice choiceWithText:@"Radiology Technician" value:@"radiology"];
    ORKTextChoice *farming = [ORKTextChoice choiceWithText:@"Farming" value:@"farming"];
    ORKTextChoice *tsaAgent = [ORKTextChoice choiceWithText:@"TSA Agent" value:@"tsaAgent"];
    ORKTextChoice *coalOilGas = [ORKTextChoice choiceWithText:@"Coal/Oil/Gas Extraction" value:@"coalOilGas"];
    ORKTextChoice *veteran = [ORKTextChoice choiceWithText:@"Military Veteran" value:@"veteran"];
    ORKTextChoice *doctor = [ORKTextChoice choiceWithText:@"Doctor/Nurse" value:@"doctor"];
    ORKTextChoice *welding = [ORKTextChoice choiceWithText:@"Welding/Soldering" value:@"welding"];
    ORKTextChoice *electrician = [ORKTextChoice choiceWithText:@"Electrician" value:@"electrician"];
    ORKTextChoice *researcher = [ORKTextChoice choiceWithText:@"Biomedical Researcher" value:@"researcher"];
    ORKTextChoice *none = [ORKTextChoice choiceWithText:@"None of the above choices" value:@"none"];
    
    NSArray *professionChoices = @[researcher,coalOilGas,construction,dental,doctor,electrician,farming,veteran,pilot,radiology,tsaAgent,welding,none,];
    ORKValuePickerAnswerFormat *profession =
    [ORKValuePickerAnswerFormat valuePickerAnswerFormatWithTextChoices:professionChoices];
    ORKQuestionStep *professionStep = [ORKQuestionStep questionStepWithIdentifier:@"profession"
                                                                            title:@"Have you worked in any of the following professions?"
                                                                           answer:profession];
    
    NSMutableArray *medicalItems = [NSMutableArray new];
    ORKFormStep *medicalInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"medicalInfo"
                                      title:@"Medical Information"
                                       text:@""];
    
    ORKAnswerFormat *historyMelanoma = [ORKAnswerFormat booleanAnswerFormat];
    [medicalItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"historyMelanoma"
                                                               text:@"Have you ever been diagnosed with melanoma?"
                                                       answerFormat:historyMelanoma]];
    
    ORKAnswerFormat *familyHistory = [ORKAnswerFormat booleanAnswerFormat];
    [medicalItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"familyHistory"
                                                               text:@"Has a blood relative (parent, sibling, child) ever had melanoma?"
                                                       answerFormat:familyHistory]];
    
    ORKAnswerFormat *moleRemoved = [ORKAnswerFormat booleanAnswerFormat];
    [medicalItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"moleRemoved"
                                                               text:@"Have you ever had a mole removed?"
                                                       answerFormat:moleRemoved]];
    
    ORKAnswerFormat *autoimmune = [ORKAnswerFormat booleanAnswerFormat];
    [medicalItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"autoImmune"
                                                               text:@"Do you have an autoimmune condition (Psoriasis, Crohn's disease, or others)?"
                                                       answerFormat:autoimmune]];
    
    ORKAnswerFormat *immunocompromised = [ORKAnswerFormat booleanAnswerFormat];
    [medicalItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"immunocompromised"
                                                               text:@"Do you have a weakened immune system for any reason (transplant recipient, lupus, prescribed drugs that suppress the immune system)?"
                                                       answerFormat:immunocompromised]];
    
    medicalInfo.formItems = medicalItems;
    
    ORKInstructionStep *thankYouStep = [[ORKInstructionStep alloc] initWithIdentifier:@"thankYou"];
    thankYouStep.title = @"Thank You!";
    thankYouStep.text = @"Your participation in this study is helping us to better understand melanoma risk and skin health\n\nYour task now is to map and measure your moles each month. You don't have to get them all, but the more the better!\n\nHappy Mapping!";
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[introStep,
                                                                      basicInfo,
                                                                      hairEyesInfo,
                                                                      professionStep,
                                                                      medicalInfo,
                                                                      thankYouStep
                                                                      ]];
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
    NSDate *dateOfLastSurveyCompleted = taskResult.endDate;
    
    
    switch (reason)
    {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            
            NSLog(@"User completed the initial module successfully");
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setValue:dateOfLastSurveyCompleted forKey:@"dateOfLastSurveyCompleted"];
            [ud setBool:YES forKey:@"showDemoInfo"];
            [ud setBool:NO forKey:@"shouldShowOnboarding"];
            NSDictionary *parsedData = [self parsedDataFromTaskResult:taskResult];
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [ad.bridgeManager signInAndSendInitialData:parsedData];
            
            
            /* This shouldn't be needed because all of the consent has been taken care of already during signup
            [ad.bridgeManager sendUserConsentedToBridgeOnCompletion:^(NSError *error){
                NSLog(@"Updated birthdate for User Profile");
                [ad.bridgeManager updateProfileOnCompletion:nil];
            }];
            */
             
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            [ad showBodyMap];
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
        [self showInitialSurvey];
    }];
    
    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self.presentingVC presentViewController:leaveOnboarding animated:YES completion:nil];
    
}

//Schema expected by Bridge
/*
 initialData
 initialData.json.autoImmune - int
 initialData.json.birthyear - string
 initialData.json.eyeColor - string
 initialData.json.familyHistory - int
 initialData.json.gender - string
 initialData.json.hairColor - string
 initialData.json.immunocompromised - int
 initialData.json.melanomaDiagnosis - int
 initialData.json.moleRemoved - int
 initialData.json.profession - string
 initialData.json.shortenedZip - string
 */

-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUInteger numberOfDigitsInDeidentifiedZipcode = 3;
    
    NSString *birthyear = @"";
    NSString *gender = @"";
    NSString *shortenedZip = @"";
    NSString *hairColor = @"";
    NSString *eyeColor = @"";
    NSString *profession = @"";
    NSNumber *melanomaDiagnosis;
    NSNumber *familyHistory;
    NSNumber *moleRemoved;
    NSNumber *autoImmune;
    NSNumber *immunocompromised;
    
    NSArray *firstLevelResults = taskResult.results;
    for (ORKCollectionResult *firstLevel in firstLevelResults)
    {
        if ([firstLevel.identifier isEqualToString:@"intro"])
        {
            NSLog(@"Processing intro here");
            continue;
        }
        else if ([firstLevel.identifier isEqualToString:@"basicInfo"])
        {
            NSLog(@"Processing basicInfo here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"dateOfBirth"])
                {
                    if ([secondLevel isKindOfClass:[ORKDateQuestionResult class]])
                    {
                        ORKDateQuestionResult *dobResult = (ORKDateQuestionResult *)secondLevel;
                        NSDate *dob = dobResult.dateAnswer;
                        
                        //Profile data needs to have an NSDate
                        ad.user.birthdateForProfile = dob;
                        
                        //Just birthyear here for de-identified data in Synapse
                        NSDateFormatter *formatForYear = [[NSDateFormatter alloc] init];
                        [formatForYear setDateFormat:@"yyyy"];
                        NSString *yearString = [formatForYear stringFromDate:dob];
                        birthyear = yearString;
                        
                        NSDateFormatter *formatForBirthdate = [[NSDateFormatter alloc] init];
                        [formatForBirthdate setDateFormat:@"yyyy-MM-dd"]; //FOR UNKNOWN REASONS THE MM MUST BE CAPITALIZED
                        NSString *birthdate = [formatForBirthdate stringFromDate:dob];
                        ad.user.birthdate = birthdate;
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"gender"])
                {
                    if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                    {
                        ORKChoiceQuestionResult *genderResult = (ORKChoiceQuestionResult *)secondLevel;
                        gender = genderResult.choiceAnswers[0];
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"zipCode"])
                {
                    if ([secondLevel isKindOfClass:[ORKNumericQuestionResult class]])
                    {
                        ORKNumericQuestionResult *zipResult = (ORKNumericQuestionResult *)secondLevel;
                        NSNumber *zip = zipResult.numericAnswer;
                        NSString *zipString = [zip stringValue];
                        ad.user.zipCode = zipString;
                        
                        //Shortened zip code here for de-identified data going to Synapse
                        NSString *zipCode = zipString;
                        if ([zipCode length] > numberOfDigitsInDeidentifiedZipcode)
                        {
                            shortenedZip = [zipCode substringToIndex:numberOfDigitsInDeidentifiedZipcode];
                        }
                    }
                }
            }
        }
        else if ([firstLevel.identifier isEqualToString:@"hairEyesInfo"])
        {
            NSLog(@"Processing hairEyesInfo here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"hairColor"])
                {
                    if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                    {
                        ORKChoiceQuestionResult *hairColorResult = (ORKChoiceQuestionResult *)secondLevel;
                        hairColor = hairColorResult.choiceAnswers[0];
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"eyeColor"])
                {
                    if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                    {
                        ORKChoiceQuestionResult *eyeColorResult = (ORKChoiceQuestionResult *)secondLevel;
                        eyeColor = eyeColorResult.choiceAnswers[0];
                    }
                }
            }
            
        }
        else if ([firstLevel.identifier isEqualToString:@"profession"])
        {
            NSLog(@"Processing profession here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                {
                    ORKChoiceQuestionResult *professionResult = (ORKChoiceQuestionResult *)secondLevel;
                    profession = professionResult.choiceAnswers[0];
                }
            }
        }
        else if ([firstLevel.identifier isEqualToString:@"medicalInfo"])
        {
            NSLog(@"Processing medicalInfo here");
            
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"historyMelanoma"])
                {
                    if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                    {
                        ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                        NSNumber *booleanAnswer = ([booleanResult.booleanAnswer isEqual:@1]) ? @1 : @0;
                        melanomaDiagnosis = booleanAnswer;
                        ad.user.melanomaStatus = [melanomaDiagnosis stringValue];
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"familyHistory"])
                {
                    if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                    {
                        ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                        NSNumber *booleanAnswer = ([booleanResult.booleanAnswer isEqual:@1]) ? @1 : @0;
                        familyHistory = booleanAnswer;
                        ad.user.familyHistory = [familyHistory stringValue];
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"moleRemoved"])
                {
                    if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                    {
                        ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                        NSNumber *booleanAnswer = ([booleanResult.booleanAnswer isEqual:@1]) ? @1 : @0;
                        moleRemoved = booleanAnswer;
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"autoImmune"])
                {
                    if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                    {
                        ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                        NSNumber *booleanAnswer = ([booleanResult.booleanAnswer isEqual:@1]) ? @1 : @0;
                        autoImmune = booleanAnswer;
                    }
                }
                else if ([secondLevel.identifier isEqualToString:@"immunocompromised"])
                {
                    if ([secondLevel isKindOfClass:[ORKBooleanQuestionResult class]])
                    {
                        ORKBooleanQuestionResult *booleanResult = (ORKBooleanQuestionResult *)secondLevel;
                        NSNumber *booleanAnswer = ([booleanResult.booleanAnswer isEqual:@1]) ? @1 : @0;
                        immunocompromised = booleanAnswer;
                    }
                }
            }
        }
        else if ([firstLevel.identifier isEqualToString:@"thankYou"])
        {
            NSLog(@"Processing thankYou here");
            continue;
            
        }
        else
        {
            NSLog(@"Unknown task with identifier: %@",firstLevel.identifier);
        }
    }
    
    //Consider storing some of this data locally in NSUserDefaults?
    [parsedData setValue:birthyear forKey:@"birthyear"];
    [parsedData setValue:gender forKey:@"gender"];
    [parsedData setValue:shortenedZip forKey:@"shortenedZip"];
    [parsedData setValue:hairColor forKey:@"hairColor"];
    [parsedData setValue:eyeColor forKey:@"eyeColor"];
    [parsedData setValue:profession forKey:@"profession"];
    [parsedData setValue:melanomaDiagnosis forKey:@"melanomaDiagnosis"];
    [parsedData setValue:familyHistory forKey:@"familyHistory"];
    [parsedData setValue:moleRemoved forKey:@"moleRemoved"];
    [parsedData setValue:autoImmune forKey:@"autoImmune"];
    [parsedData setValue:immunocompromised forKey:@"immunocompromised"];
    
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
