//
//  SharingOptionsOnlyRKModule.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
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


#import "SharingOptionsOnlyRKModule.h"
#import "AppDelegate.h"
#import "SBBUserProfile+MoleMapper.h"
#import "ResearchKit.h"
#import "PopupManager.h"

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
            NSNumber *sharingScope = @0;
            
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
                            if ([sharingScopeNumber  isEqual: @1]) {sharingScope = @2;}
                            else if ([sharingScopeNumber isEqual:@0]) {sharingScope = @1;}
                            else {sharingScope = @0;}
                        }
                    }
                    
                }
            }
            
            //Store appropriate values securely in MMUser as strings
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSString *text = @"Your selection for how your data is shared with researchers has been saved.";
            [[PopupManager sharedInstance] createPopupWithText:text andSize:24.0];
            
            ad.user.sharingScope = sharingScope;
            [ad.bridgeManager signInAndChangeSharingToScope:sharingScope];
            
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
    return @"This study gives you the option to share your data in 2 ways:\n\n1- Share with the research world (“Share broadly”):  You can choose to share your study data with the study team and its partners and your coded study data with qualified researchers worldwide for use in this and future academic and commercial research.  Coded study data is data that does not include personal information such as your name or email. Qualified researchers are registered users of Synapse who have agreed to use the data in an ethical manner for research purposes, and have agreed to not attempt to re-identify you.  If you choose to share your coded study data broadly, the metadata (your response to survey questions and the mole measurements without the mole photo) will be added to a shared dataset available to qualified researchers on the Sage Bionetworks Synapse servers at synapse.org.  Your mole photos will be available to qualified researchers who have received ethical approval to use the photos for their research.  Sage Bionetworks will have no oversight on the future research that qualified researchers may conduct with the coded study data.\n\n2- Only share with the study team (“Share sparsely”): You can choose to share your study data only with the study team and its partners.  The study team includes the Principal Investigator of the research and any other researchers or partners named in the consent document. Sharing your study data this way means that your data will not be made available to anyone other than those listed in the consent document and for the purposes of this study only. Note that your name and contact information will be included in the OHSU War on Melanoma Community Registry.\n\nIf required by law, your study data, account information and the signed consent form may be disclosed to:\n-The US Department of Health and Human Services, the Office for Human Research Protection, and other agencies for verification of the research procedures and data.\n-Institutional Review Board who monitors the safety, effectiveness and conduct of the research being conducted,The results of this research study may be presented at meetings or in publications. If the results of this study are made public, only coded study data and de-identified mole photos will be used, that is, your personal information will not be disclosed.\n\nYou can change the data sharing setting though the app preference at anytime.  For additional information review the study privacy policy.";
}

@end
