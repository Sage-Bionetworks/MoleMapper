//
//  MMUser.h
//  MoleMapper
//
//  Created by Dan Webster on 9/5/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Derived from APCUser to store user data and their relevant
 BridgeProfile information. All properties (except listed exceptions)
 are stored as strings in the keychain for security purposes
 */

@interface MMUser : NSObject

@property (strong, nonatomic) NSString *bridgeSignInEmail;
@property (strong, nonatomic) NSString *bridgeSignInPassword;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *melanomaStatus;
@property (strong, nonatomic) NSString *familyHistory;
@property (strong, nonatomic) NSString *externalID;
@property (strong, nonatomic) NSString *birthdate;
@property BOOL hasConsented;
@property BOOL hasEnrolled;

//Note that this is stored as @0, @1, @2 which will be converted by SBBConsentManager to appropriate string
//0 = no_sharing, 1 = sponsors_and_partners, 2 = all_qualified_researchers
@property (strong, nonatomic) NSNumber *sharingScope;

//Storing as NSDate here for the Profile because SBBConsentManager needs to have a date rather than a formatted
//string like that in the initial data survey
@property (strong, nonatomic) NSDate *birthdateForProfile;

//Storing the NSData in documents directory and calling back up on the fly here
@property (strong, nonatomic) UIImage *signatureImage;

//Storing the NSData in documents directory and calling back up on the fly here
@property (strong, nonatomic) NSData *consentPDF;

// This is an array of dictionaries that have the following structure
// "moleID" -> (NSNumber *)moleID,
// "diagnoses -> (NSArray *)[array of diagnoses (NSStrings)]
// This is all stored in NSUserDefaults
@property (strong, nonatomic) NSArray *removedMolesToDiagnoses;

//Storage of all of the measurements (their measurementIDs) that have already been successfully shipped to Bridge
@property (strong, nonatomic) NSArray *measurementsAlreadySentToBridge;

@end
