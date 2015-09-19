//
//  ProfileRKLaunchPad.h
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Serves as a 'launch pad' view controller from which to host the ResearchKit Modules that will only apply to the profile, as opposed to the onboarding process
 */
@interface ProfileRKLaunchPad : UIViewController

@property BOOL shouldShowSharingOptions;
@property BOOL shouldShowReviewConsent;
@property BOOL shouldShowExternalID;

@end
