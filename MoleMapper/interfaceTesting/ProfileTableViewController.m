//
//  ProfileTableViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 9/11/15.
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


#import "ProfileTableViewController.h"
#import "AppDelegate.h"
#import "MMUser.h"
#import "SBBUserProfile+MoleMapper.h"
#import "PDFViewerViewController.h"
#import "ProfileRKLaunchPad.h"
#import "ReviewConsentOnlyRKModule.h"
#import "ExternalIDRKModule.h"

@interface ProfileTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *enrollmentStatus;
@property (weak, nonatomic) IBOutlet UITableViewCell *sharingOptions;

#define NAME_OF_PRIVACY_POLICY_DOC @"privacyPolicy_2016_05_27"
#define NAME_OF_INFORMATION_SHEET_DOC @"WoM-Information.Sheet.revisions.TRACKED_2015_10_09"
#define NAME_OF_CONSENT_FORM @"consentForm_16038_2016_05_27"

@end

@implementation ProfileTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //Set up any customized labels here if needed
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL userHasEnrolled = ad.user.hasEnrolled;
    if (userHasEnrolled == YES)
    {
        self.enrollmentStatus.textLabel.text = @"Leave Study";
        self.enrollmentStatus.detailTextLabel.text = @"Participating";
        self.enrollmentStatus.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:255.0 alpha:1.0];
        self.sharingOptions.userInteractionEnabled = YES;
        self.sharingOptions.textLabel.enabled = YES;
        self.sharingOptions.detailTextLabel.enabled = YES;
        self.sharingOptions.textLabel.alpha = 1.0;
    }
    else
    {
        self.enrollmentStatus.textLabel.text = @"Join Study";
        self.enrollmentStatus.detailTextLabel.text = @"Not Participating";
        self.enrollmentStatus.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:255.0 alpha:1.0];
        self.sharingOptions.userInteractionEnabled = NO;
        self.sharingOptions.textLabel.enabled = NO;
        self.sharingOptions.detailTextLabel.enabled = NO;
        self.sharingOptions.textLabel.alpha = 0.5;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self leaveOrJoinResearchStudyTapped:nil];
    }
    if (indexPath.section == 2)
    {
        [self showChoiceForReviewConsent];
    }
}

-(void)showChoiceForReviewConsent
{
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"How would you like to review consent?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *screens = [UIAlertAction actionWithTitle:@"Consent Screens" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        [self performSegueWithIdentifier:@"consentScreens" sender:self];
        
    }];
    
    UIAlertAction *form = [UIAlertAction actionWithTitle:@"Consent Form" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self performSegueWithIdentifier:@"consentForm" sender:self];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    
    [leaveOnboarding addAction:screens];
    [leaveOnboarding addAction:form];
    [leaveOnboarding addAction:cancel];
    
    [self presentViewController:leaveOnboarding animated:YES completion:nil];
}
/*
UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Email Verification Resent", @"") message:error.localizedDescription];

[self presentViewController:alert animated:YES completion:nil];
*/

- (void)leaveOrJoinResearchStudyTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BOOL userHasEnrolled = ad.user.hasEnrolled;
    
    if (userHasEnrolled) //They would be tapping to leave study
    {
        UIAlertController *leaveStudy = [UIAlertController alertControllerWithTitle:@"Leave Study" message:@"Are you sure you want to leave the study?\nThis action cannot be undone and you will need to provide consent in order to re-enroll." preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Leave Study" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [ad.bridgeManager signInAndChangeSharingToScope:@0];
            
            ad.user.sharingScope = @0;
            ad.user.hasEnrolled = NO;
            ad.user.hasConsented = NO;
            ad.user.bridgeSignInEmail = nil;
            ad.user.bridgeSignInPassword = nil;
            
            self.enrollmentStatus.textLabel.text = @"Join Study";
            self.enrollmentStatus.detailTextLabel.text = @"Not Participating";
            self.enrollmentStatus.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:255.0 alpha:1.0];
            
            self.sharingOptions.userInteractionEnabled = NO;
            self.sharingOptions.textLabel.enabled = NO;
            self.sharingOptions.detailTextLabel.enabled = NO;
            self.sharingOptions.textLabel.alpha = 0.5;
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [leaveStudy addAction:leave];
        [leaveStudy addAction:cancel];
        
        [self presentViewController:leaveStudy animated:YES completion:nil];
    }
    else //User wants to enroll in the study
    {
        UIAlertController *joinStudy = [UIAlertController alertControllerWithTitle:@"Join Study" message:@"Tap 'Join Study' to learn more about the research study, your eligibility, and the consent process" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *join = [UIAlertAction actionWithTitle:@"Join Study" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [ad setOnboardingBooleansBackToInitialValues];
            [ad showCorrectOnboardingScreenOrBodyMap];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [joinStudy addAction:join];
        [joinStudy addAction:cancel];
        
        [self presentViewController:joinStudy animated:YES completion:nil];
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"privacyPolicy"])
    {
        PDFViewerViewController *destVC = (PDFViewerViewController *)[segue destinationViewController];
        destVC.filename = NAME_OF_PRIVACY_POLICY_DOC;
    }
    else if ([segue.identifier isEqualToString:@"sharingOptions"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowSharingOptions = YES;
    }
    else if ([segue.identifier isEqualToString:@"consentScreens"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowReviewConsent = YES;
    }
    /*
    else if ([segue.identifier isEqualToString:@"externalID"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowExternalID = YES;
    }
     */
    else if ([segue.identifier isEqualToString:@"informationSheet"])
    {
        PDFViewerViewController *destVC = (PDFViewerViewController *)[segue destinationViewController];
        destVC.filename = NAME_OF_INFORMATION_SHEET_DOC;
    }
    
    else if ([segue.identifier isEqualToString:@"consentForm"])
    {
        PDFViewerViewController *destVC = (PDFViewerViewController *)[segue destinationViewController];
        destVC.filename = NAME_OF_CONSENT_FORM;
    }
}


@end
