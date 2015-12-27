//
//  MMUser.m
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

#import "MMUser.h"
#import "APCKeychainStore.h"

@implementation MMUser

#pragma mark - accessor methods for user data
-(NSString *)bridgeSignInEmail
{
    NSString *email = [APCKeychainStore stringForKey:@"bridgeSignInEmail"];
    return email;
}

-(void)setBridgeSignInEmail:(NSString *)bridgeSignInEmail
{
    if (bridgeSignInEmail != nil)
    {
        [APCKeychainStore setString:bridgeSignInEmail forKey:@"bridgeSignInEmail"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"bridgeSignInEmail"];
    }
}

-(NSString *)bridgeSignInPassword
{
    NSString *bridgeSignInPassword = [APCKeychainStore stringForKey:@"bridgeSignInPassword"];
    return bridgeSignInPassword;
}

-(void)setBridgeSignInPassword:(NSString *)bridgeSignInPassword
{
    if (bridgeSignInPassword != nil)
    {
        [APCKeychainStore setString:bridgeSignInPassword forKey:@"bridgeSignInPassword"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"bridgeSignInPassword"];
    }
}

-(NSString *)firstName
{
    NSString *firstName = [APCKeychainStore stringForKey:@"firstName"];
    return firstName;
}

-(void)setFirstName:(NSString *)firstName
{
    if (firstName != nil)
    {
        [APCKeychainStore setString:firstName forKey:@"firstName"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"firstName"];
    }
}

-(NSString *)lastName
{
    NSString *lastName = [APCKeychainStore stringForKey:@"lastName"];
    return lastName;
}

-(void)setLastName:(NSString *)lastName
{
    if (lastName != nil)
    {
        [APCKeychainStore setString:lastName forKey:@"lastName"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"lastName"];
    }
}

-(NSString *)zipCode
{
    NSString *zipCode = [APCKeychainStore stringForKey:@"zipCode"];
    return zipCode;
}

-(void)setZipCode:(NSString *)zipCode
{
    if (zipCode != nil)
    {
        [APCKeychainStore setString:zipCode forKey:@"zipCode"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"zipCode"];
    }
}

-(NSNumber *)sharingScope
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *sharingScope = [ud objectForKey:@"sharingScope"];
    return sharingScope;
}

-(void)setSharingScope:(NSNumber *)sharingScope
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:sharingScope forKey:@"sharingScope"];
}

-(NSString *)melanomaStatus
{
    NSString *melanomaStatus = [APCKeychainStore stringForKey:@"melanomaStatus"];
    return melanomaStatus;
}

-(void)setMelanomaStatus:(NSString *)melanomaStatus
{
    if (melanomaStatus != nil)
    {
        [APCKeychainStore setString:melanomaStatus forKey:@"melanomaStatus"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"melanomaStatus"];
    }
}

-(NSString *)familyHistory
{
    NSString *familyHistory = [APCKeychainStore stringForKey:@"familyHistory"];
    return familyHistory;
}

-(void)setFamilyHistory:(NSString *)familyHistory
{
    if (familyHistory != nil)
    {
        [APCKeychainStore setString:familyHistory forKey:@"familyHistory"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"familyHistory"];
    }
}

-(NSString *)externalID
{
    NSString *externalID = [APCKeychainStore stringForKey:@"externalID"];
    return externalID;
}

-(void)setExternalID:(NSString *)externalID
{
    if (externalID != nil)
    {
        [APCKeychainStore setString:externalID forKey:@"externalID"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"externalID"];
    }
}

-(NSString *)birthdate
{
    NSString *birthdate = [APCKeychainStore stringForKey:@"birthdate"];
    return birthdate;
}

-(void)setBirthdate:(NSString *)birthdate
{
    if (birthdate != nil)
    {
        [APCKeychainStore setString:birthdate forKey:@"birthdate"];
    }else
    {
        [APCKeychainStore removeValueForKey:@"birthdate"];
    }
}

-(NSDate *)birthdateForProfile
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDate *birthdateForProfile = [ud objectForKey:@"birthdateForProfile"];
    return birthdateForProfile;
}

-(void)setBirthdateForProfile:(NSDate *)birthdateForProfile
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:birthdateForProfile forKey:@"birthdateForProfile"];
}

-(UIImage *)signatureImage
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *signatureImageFilename = @"signatureImage.png";
    UIImage *signatureImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsDirectory, signatureImageFilename]];
    return signatureImage;
}

-(void)setSignatureImage:(UIImage *)signatureImage
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [UIImagePNGRepresentation(signatureImage) writeToFile:[documentsDirectory stringByAppendingPathComponent:@"signatureImage.png"] options:NSAtomicWrite error:nil];
}

-(NSData *)consentPDF
{
    NSData *consentPDF = [NSData data];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *consentPDFfilename = @"consentDocument.pdf";
    NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, consentPDFfilename];
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        consentPDF = [[NSFileManager defaultManager] contentsAtPath:filepath];
    }
    else{NSLog(@"Trying to retrieve PDF data that doesn't exist!");}
    return consentPDF;
}

-(void)setConsentPDF:(NSData *)consentPDF
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [consentPDF writeToFile:[documentsDirectory stringByAppendingPathComponent:@"consentDocument.pdf"] atomically:YES];
}

-(BOOL)hasConsented
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL userHasConsented = [ud boolForKey:@"userHasConsented"];
    return userHasConsented;
}

-(void)setHasConsented:(BOOL)userHasConsented
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:userHasConsented forKey:@"userHasConsented"];
}

-(BOOL)hasEnrolled
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL userHasEnrolled = [ud boolForKey:@"userHasEnrolled"];
    return userHasEnrolled;
}

-(void)setHasEnrolled:(BOOL)hasEnrolled
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:hasEnrolled forKey:@"userHasEnrolled"];
}

-(NSArray *)removedMolesToDiagnoses
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *removedMolesToDiagnoses = [ud objectForKey:@"removedMolesToDiagnoses"];
    return removedMolesToDiagnoses;
}

-(void)setRemovedMolesToDiagnoses:(NSArray *)removedMolesToDiagnoses
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (removedMolesToDiagnoses != nil)
    {
        [ud setObject:removedMolesToDiagnoses forKey:@"removedMolesToDiagnoses"];
    }
}

-(NSArray *)measurementsAlreadySentToBridge
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *measurementsAlreadySentToBridge = [ud objectForKey:@"measurementsAlreadySentToBridge"];
    return measurementsAlreadySentToBridge;
}

-(void)setMeasurementsAlreadySentToBridge:(NSArray *)measurementsAlreadySentToBridge
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (measurementsAlreadySentToBridge != nil)
    {
        [ud setObject:measurementsAlreadySentToBridge forKey:@"measurementsAlreadySentToBridge"];
    }

}

@end
