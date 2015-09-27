//
//  MMUser.m
//  MoleMapper
//
//  Created by Dan Webster on 9/5/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
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

@end
