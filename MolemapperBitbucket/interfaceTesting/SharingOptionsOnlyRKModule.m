//
//  SharingOptionsOnlyRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "SharingOptionsOnlyRKModule.h"
#import "AppDelegate.h"
#import "SBBUserProfile+MoleMapper.h"
#import "ResearchKit.h"

@interface SharingOptionsOnlyRKModule ()

@property (strong, nonatomic) NSString *sharingStepDetails;


@end

@implementation SharingOptionsOnlyRKModule

-(void)showSharing
{
    ORKOrderedTask *task = nil;
    
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"sharingStep"
                         investigatorShortDescription:@"The Mole Mapper Study Team"
                          investigatorLongDescription:@"The Mole Mapper Study Team and its partners"
                        localizedLearnMoreHTMLContent:self.sharingStepDetails];
    
    task = [[ORKOrderedTask alloc] initWithIdentifier:@"task" steps:@[sharingStep]];
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
            NSString *sharingScope = @"";
            
            NSArray *firstLevelResults = taskResult.results;
            for (ORKCollectionResult *firstLevel in firstLevelResults)
            {
                if ([firstLevel.identifier isEqualToString:@"sharingStep"])
                {
                    NSLog(@"Processing sharingStep here");
                    for (ORKStepResult *secondLevel in firstLevel.results)
                    {
                        if ([secondLevel isKindOfClass:[ORKChoiceQuestionResult class]])
                        {
                            //OK, below is some wackiness having to do with ResearchKit vs BridgeServer, but just go with it
                            ORKChoiceQuestionResult *sharingResult = (ORKChoiceQuestionResult *)secondLevel;
                            NSNumber *sharingScopeNumber = sharingResult.choiceAnswers[0];
                            sharingScopeNumber = sharingScopeNumber;
                            if ([sharingScopeNumber  isEqual: @1]) {sharingScope = @"2";}
                            else if ([sharingScopeNumber isEqual:@0]) {sharingScope = @"1";}
                            else {sharingScope = @"0";}
                        }
                    }
                    
                }
            }
            
            //Store appropriate values securely in MMUser as strings
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            ad.user.sharingScope = sharingScope;
            
            [ad.bridgeManager sendUserConsentedToBridgeOnCompletion:^(NSError *error){
                NSLog(@"User has changed their sharingScope to %@",sharingScope);
            }];
            
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
    [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
    [self.presentingVC.navigationController popViewControllerAnimated:YES];
}

-(NSString *)sharingStepDetails
{
    return @"This study gives you the option to share your data in 2 ways:\n\n1- Share with the research world:  You can choose to share your coded study data with qualified researchers worldwide for use in this and future academic and commercial research.  Coded study data is data that does not include personal information such as your name or email. Qualified researchers are registered users of Synapse who have agreed to use the data in an ethical manner for research purposes, and have agreed to not attempt to re-identify you.  If you choose to share your coded study data broadly, the metadata (your response to survey questions and the mole measurements without the mole photo) will be added to a shared dataset available to qualified researchers on the Sage Bionetworks Synapse servers at synapse.org.  Your mole photos will be available to qualified researchers who have received ethical approval to use the photos for their research.  Sage Bionetworks will have no oversight on the future research that qualified researchers may conduct with the coded study data.\n\n2- Only share with the study team: You can choose to share your study data only with the study team and its partners.  The study team includes the sponsor of the research and any other researchers or partners named in the consent document. Sharing your study data this way means that your data will not be made available to anyone other than those listed in the consent document and for the purposes of this study only.Note that limited information about you will be included in the OHSU War on Melanoma Community Registry.\n\nIf required by law, your study data, account information and the signed consent form may be disclosed to:\nThe US Department of Health and Human Services, the Office for Human Research Protection, and other agencies for verification of the research procedures and data.\nInstitutional Review Board who monitors the safety, effectiveness and conduct of the research being conducted\n\nThe results of this research study may be presented at meetings or in publications. If the results of this study are made public, only coded study data and de-identified mole photos will be used, that is, your personal information will not be disclosed.\n\nYou can change the data sharing setting though the app preference at anytime.  For additional information review the study privacy policy";
}

@end
