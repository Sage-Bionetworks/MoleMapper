//
//  ExternalIDRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/17/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "ExternalIDRKModule.h"
#import "AppDelegate.h"

@implementation ExternalIDRKModule

//Create a very simple ResearchKit survey for user data entry for email and password
-(void)showExternalID
{
    NSMutableArray *externalIDItems = [NSMutableArray new];
    ORKFormStep *externalIDInfo =
    [[ORKFormStep alloc] initWithIdentifier:@"externalID"
                                      title:@"External ID"
                                       text:@"The External ID functionality enables you to link your Mole Mapper data to an external data record.\n\nPlease enter the External ID below if you received one (Optional)"];
    externalIDInfo.optional = NO;
    
    ORKTextAnswerFormat *externalID = [ORKAnswerFormat textAnswerFormat];
    externalID.multipleLines = NO;
    externalID.spellCheckingType = UITextSpellCheckingTypeNo;
    externalID.autocapitalizationType = UITextAutocapitalizationTypeNone;
    externalID.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [externalIDItems addObject:[[ORKFormItem alloc] initWithSectionTitle:@"\n\n"]];
    
    [externalIDItems addObject:[[ORKFormItem alloc] initWithIdentifier:@"externalID"
                                                              text:@"External ID"
                                                      answerFormat:externalID]];
    
    externalIDInfo.formItems = externalIDItems;
    
    ORKOrderedTask *task =
    [[ORKOrderedTask alloc] initWithIdentifier:@"externalID"
                                         steps:@[externalIDInfo]];
    
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
            
            NSString *externalID = [parsedData valueForKey:@"externalID"];
            
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            ad.user.externalID = externalID;
            
            if (ad.user.hasConsented)
            {
                [SBBComponent(SBBUserManager) addExternalIdentifier:externalID
                                                         completion:^(id responseObject, NSError *error) {
                                                             NSLog(@"Added External ID for user");
                                                             NSLog(@"Response: %@",responseObject);
                                                             NSLog(@"Error: %@",error);
                                                        }];
            }
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
    [self.presentingVC dismissViewControllerAnimated:NO completion:nil];
    [self.presentingVC.navigationController popViewControllerAnimated:YES];;
    
}

-(NSDictionary *)parsedDataFromTaskResult:(ORKTaskResult *)taskResult
{
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionary];
    
    NSString *externalID = @"";
    
    NSArray *firstLevelResults = taskResult.results;
    for (ORKCollectionResult *firstLevel in firstLevelResults)
    {
        if ([firstLevel.identifier isEqualToString:@"externalID"])
        {
            NSLog(@"Processing ExternalID here");
            for (ORKStepResult *secondLevel in firstLevel.results)
            {
                if ([secondLevel.identifier isEqualToString:@"externalID"])
                {
                    if ([secondLevel isKindOfClass:[ORKTextQuestionResult class]])
                    {
                        ORKTextQuestionResult *textResult = (ORKTextQuestionResult *)secondLevel;
                        externalID = textResult.textAnswer;
                    }
                }
            }
        }
        
        else
        {
            NSLog(@"Unknown task with identifier: %@",firstLevel.identifier);
        }
    }
    
    [parsedData setValue:externalID forKey:@"externalID"];
    
    return parsedData;
}


@end
