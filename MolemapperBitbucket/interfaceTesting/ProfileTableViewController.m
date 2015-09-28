//
//  ProfileTableViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 9/11/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
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
//@property (weak, nonatomic) IBOutlet UITableViewCell *sharingOptions;

#define NAME_OF_PRIVACY_POLICY_DOC @"PrivacyPolicy-MoleMapper-20Sept2015-EN"

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
    }
    else
    {
        self.enrollmentStatus.textLabel.text = @"Join Study";
        self.enrollmentStatus.detailTextLabel.text = @"Not Participating";
        self.enrollmentStatus.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:255.0 alpha:1.0];
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
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [leaveStudy addAction:leave];
        [leaveStudy addAction:cancel];
        
        [self presentViewController:leaveStudy animated:YES completion:nil];
    }
    else //User wants to enroll in the study
    {
        UIAlertController *joinStudy = [UIAlertController alertControllerWithTitle:@"Join Study" message:@"Tap 'Join Study' to learn more about the research study, your eligibility, and the consent process" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *join = [UIAlertAction actionWithTitle:@"Join Study" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [ad setOnboardingBooleansBackToInitialValues];
            [ad showOnboarding];
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
    else if ([segue.identifier isEqualToString:@"reviewConsent"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowReviewConsent = YES;
    }
    else if ([segue.identifier isEqualToString:@"externalID"])
    {
        ProfileRKLaunchPad *destVC = (ProfileRKLaunchPad *)[segue destinationViewController];
        destVC.shouldShowExternalID = YES;
    }
}


@end
