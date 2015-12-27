//
//  MMUser.h
//  MoleMapper
//
//  Created by Dan Webster on 9/5/15.
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
