//
//  ProfileRKLaunchPad.m
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "ProfileRKLaunchPad.h"
#import "AppDelegate.h"
#import "SharingOptionsOnlyRKModule.h"
#import "ReviewConsentOnlyRKModule.h"
#import "ExternalIDRKModule.h"
#import "FeedbackRKModule.h"

@interface ProfileRKLaunchPad ()

@property (nonatomic, strong) SharingOptionsOnlyRKModule *sharingModule;
@property (nonatomic, strong) ReviewConsentOnlyRKModule *consentOnlyModule;
@property (nonatomic, strong) ExternalIDRKModule *externalIDModule;
@property (nonatomic, strong) FeedbackRKModule *feedbackModule;

@end

@implementation ProfileRKLaunchPad

-(void)viewDidLoad
{
    if (self.shouldShowSharingOptions)
    {
        self.shouldShowSharingOptions = NO;
        self.sharingModule = [[SharingOptionsOnlyRKModule alloc] init];
        self.sharingModule.presentingVC = self;
        [self.sharingModule showSharing];
    }
    else if (self.shouldShowReviewConsent)
    {
        self.shouldShowReviewConsent = NO;
        self.consentOnlyModule = [[ReviewConsentOnlyRKModule alloc] init];
        self.consentOnlyModule.presentingVC = self;
        [self.consentOnlyModule showConsentReview];
    }
    else if (self.shouldShowExternalID)
    {
        self.shouldShowExternalID = NO;
        self.externalIDModule = [[ExternalIDRKModule alloc] init];
        self.externalIDModule.presentingVC = self;
        [self.externalIDModule showExternalID];
    }
    else if (self.shouldShowFeedback)
    {
        self.shouldShowExternalID = NO;
        self.feedbackModule = [[FeedbackRKModule alloc] init];
        self.feedbackModule.presentingVC = self;
        [self.feedbackModule showFeedback];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
