//
//  BridgeManager.m
//  MoleMapper
//
//  Created by Dan Webster on 8/19/15.
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

#import "BridgeManager.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Zone.h"
#import "ZipArchive.h"
#import "APCDataArchiveUploader.h"
#import "APCLog.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

#define SUBPOPULATION_GUID @"2e367b99-b5af-452d-8f6c-7e45f1ff756c"

//Class to handle data transfer to BridgeServer
@implementation BridgeManager

//Derived from APCUser+Bridge
- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock
{
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *name = @"Name not provided";
    NSLog(@"firstName: %@, lastName: %@",ad.user.firstName, ad.user.lastName);
    if (ad.user.firstName && ad.user.lastName)
    {
        name = [NSString stringWithFormat:@"%@ %@",ad.user.firstName,ad.user.lastName];
    }
    
    /*Because user may not have entered their birthdate yet (will happen in initial survey), but
    the bridge server call to set the consent needs a non-nill date, need to put something in,
    and this will be overwritten later when the initial survey is completed */
    NSDate *birthdate = [NSDate dateWithTimeIntervalSince1970:0.0];
    if (ad.user.birthdateForProfile)
    {
        birthdate =  ad.user.birthdateForProfile;
    }
    
    UIImage *signatureImage = ad.user.signatureImage;
    NSNumber *sharingScope = ad.user.sharingScope;
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            [SBBComponent(SBBConsentManager) consentSignature:name forSubpopulationGuid:SUBPOPULATION_GUID birthdate:birthdate signatureImage:signatureImage dataSharing:[sharingScope integerValue] completion:^(id __unused responseObject,
                                                                NSError * __unused error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!error)
                     {
                         APCLogEventWithData(@"Network Event", (@{@"event_detail":@"User Consent Sent To Bridge"}));
                     }
                     else
                     {
                         NSLog(@"Did not send consent because of this error: %@",error);
                         //NSDictionary *responseDictionary = (NSDictionary *)responseObject;
                     }
                     
                     if (completionBlock) {completionBlock(error);}
                 });
             }];
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
    
    
}

-(void)signInAndChangeSharingToScope:(NSNumber *)sharingScope
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword)
            {
                [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                        password: ad.user.bridgeSignInPassword
                                                      completion: ^(NSURLSessionDataTask * __unused task,
                                                                    id responseObject,
                                                                    NSError *signInError)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!signInError)
                         {
                             NSLog(@"User is Signed In");
                             [SBBComponent(SBBUserManager) dataSharing:[sharingScope integerValue]
                                                            completion:^(id responseObject, NSError *error) {
                                                                NSLog(@"Changed the sharing scope with this response: %@",(NSDictionary *)responseObject);
                                                            }];
                         }else{NSLog(@"Error signing In with this response: %@",(NSDictionary *)responseObject);}
                     });
                 }];
            }
            else{NSLog(@"Sign in failed because username and password not set");}

        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
    
    }

//Derived from APCUser+Bridge
- (void) updateProfileOnCompletion:(void (^)(NSError *))completionBlock
{
    /*if ([self serverDisabled]) {
     if (completionBlock) {
     completionBlock(nil);
     }
     }
     else
     {*/
    
    SBBUserProfile *profile = [SBBUserProfile new];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (ad.user.bridgeSignInEmail) {profile.email = ad.user.bridgeSignInEmail;}
    if (ad.user.bridgeSignInEmail) {profile.username = ad.user.bridgeSignInEmail;}
    if (ad.user.firstName) {profile.firstName = ad.user.firstName;}
    if (ad.user.lastName) {profile.lastName = ad.user.lastName;}
    
    //**Note** As of most recent IRB submission, this data will not be transferred to Bridge Server Profile
    // but will be securely stored locally in the keychain in case there is a change later
    //if (ad.user.zipCode) {profile.zipCode = ad.user.zipCode;}
    //if (ad.user.melanomaStatus) {profile.melanomaDiagnosis = ad.user.melanomaStatus;}
    //if (ad.user.familyHistory) {profile.familyHistory = ad.user.familyHistory;}
    //if (ad.user.birthdate) {profile.birthdate = ad.user.birthdate;}
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            [SBBComponent(SBBUserManager) updateUserProfileWithProfile: profile
                                                            completion: ^(id __unused responseObject,
                                                                          NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (!error)
                     {
                         NSLog(@"User Profile Updated To Bridge");
                     }
                     if (completionBlock)
                     {
                         completionBlock(error);
                     }
                 });
             }];
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
    
    
    
}

-(void)signInAndSendInitialData:(NSDictionary *)initialData
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
            {
                [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                        password: ad.user.bridgeSignInPassword
                                                      completion: ^(NSURLSessionDataTask * __unused task,
                                                                    id responseObject,
                                                                    NSError *signInError)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!signInError)
                         {
                             /*
                              NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                              if (responseDictionary)
                              {
                              NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                              NSLog(@"Data sharing scope integer is %@",dataSharing);
                              }
                              */
                             
                             NSLog(@"User is Signed In");
                             [ad.bridgeManager zipEncryptAndShipInitialData:initialData];
                         }
                         else
                         {
                             NSLog(@"Error during log in before followup: %@",signInError);
                         }
                         
                     });
                 }
                 ];
            }
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
    
    
}

-(void)signInAndSendFollowupData:(NSDictionary *)followupData
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
            {
                [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                        password: ad.user.bridgeSignInPassword
                                                      completion: ^(NSURLSessionDataTask * __unused task,
                                                                    id responseObject,
                                                                    NSError *signInError)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!signInError)
                         {
                             NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                             if (responseDictionary)
                             {
                                 NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                                 NSLog(@"Data sharing scope integer is %@",dataSharing);
                             }
                             
                             NSLog(@"User is Signed In");
                             [ad.bridgeManager zipEncryptAndShipFollowupData:followupData];
                         }
                         else
                         {
                             NSLog(@"Error during log in before followup: %@",signInError);
                         }
                         
                     });
                 }
                 ];
            }
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
}

-(void)signInAndSendMeasurements
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
            {
                [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                        password: ad.user.bridgeSignInPassword
                                                      completion: ^(NSURLSessionDataTask * __unused task,
                                                                    id responseObject,
                                                                    NSError *signInError)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!signInError)
                         {
                             /*
                              NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                              if (responseDictionary)
                              {
                              NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                              NSLog(@"Data sharing scope integer is %@",dataSharing);
                              }
                              */
                             
                             NSLog(@"User is Signed In");
                             [ad.bridgeManager zipEncryptAndShipAllMoleMeasurementData];
                         }
                         else
                         {
                             NSLog(@"Error during log in: %@",signInError);
                         }
                         
                     });
                 }
                 ];
            }

        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
}

-(void)signInAndSendRemovedMoleData:(NSDictionary *)removedMoleData
{
    {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
            //check for isReachable here
            if ([[AFNetworkReachabilityManager sharedManager] isReachable])
            {
                NSLog(@"Is reachable");
                if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
                {
                    [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                            password: ad.user.bridgeSignInPassword
                                                          completion: ^(NSURLSessionDataTask * __unused task,
                                                                        id responseObject,
                                                                        NSError *signInError)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (!signInError)
                             {
                                 NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                                 if (responseDictionary)
                                 {
                                     NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                                     NSLog(@"Data sharing scope integer is %@",dataSharing);
                                 }
                                 
                                 NSLog(@"User is Signed In");
                                 [ad.bridgeManager zipEncryptAndShipRemovedMoleData:removedMoleData];
                             }
                             else
                             {
                                 NSLog(@"Error during log in before removedMoleData: %@",signInError);
                             }
                             
                         });
                     }
                     ];
                }
            }
            else
            {
                NSLog(@"Is not reachable");
            }
        }];
    }

}

-(void)signInAndSendFeedback:(NSDictionary *)feedbackData
{
    {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
            //check for isReachable here
            if ([[AFNetworkReachabilityManager sharedManager] isReachable])
            {
                NSLog(@"Is reachable");
                if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
                {
                    [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                            password: ad.user.bridgeSignInPassword
                                                          completion: ^(NSURLSessionDataTask * __unused task,
                                                                        id responseObject,
                                                                        NSError *signInError)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (!signInError)
                             {
                                 NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                                 if (responseDictionary)
                                 {
                                     NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                                     NSLog(@"Data sharing scope integer is %@",dataSharing);
                                 }
                                 
                                 NSLog(@"User is Signed In");
                                 [ad.bridgeManager zipEncryptAndShipFeedbackData:feedbackData];
                             }
                             else
                             {
                                 NSLog(@"Error during log in before sending feedback: %@",signInError);
                             }
                             
                         });
                     }
                     ];
                }
            }
            else
            {
                NSLog(@"Is not reachable");
            }
        }];
    }
    
}

-(void)signInAndReEmailConsentDocForSubpopulation:(NSString *)subpopGuid andCompletionBlock:(void (^)(NSError *))completionBlock
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            if (ad.user.bridgeSignInEmail && ad.user.bridgeSignInPassword && ad.user.hasConsented == YES)
            {
                [SBBComponent(SBBAuthManager) signInWithUsername: ad.user.bridgeSignInEmail
                                                        password: ad.user.bridgeSignInPassword
                                                      completion: ^(NSURLSessionDataTask * __unused task,
                                                                    id responseObject,
                                                                    NSError *signInError)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (!signInError)
                         {
                             NSDictionary *responseDictionary = (NSDictionary *) responseObject;
                             if (responseDictionary)
                             {
                                 NSNumber *dataSharing = responseDictionary[@"dataSharing"];
                                 NSLog(@"Data sharing scope integer is %@",dataSharing);
                                 NSString *subpopGUID = responseDictionary[@"consentStatuses"][@"ohsu-molemapper"][@"subpopulationGuid"];
                                 NSLog(@"SubpopGuid: %@",subpopGUID);
                                 
                             }
                             
                             NSLog(@"Sending Re-consent email...");
                             [self emailConsentDocForSubpopulation:subpopGuid WithCompletionBlock:completionBlock];
                         }
                         else
                         {
                             NSLog(@"Error during log in before Re-sending Consent: %@",signInError);
                         }
                         
                     });
                 }
                 ];
            }
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
}

-(void)emailConsentDocForSubpopulation:(NSString *)subpopGuid WithCompletionBlock:(void (^)(NSError *))completionBlock
{
    [SBBComponent(SBBConsentManager)emailConsentForSubpopulation:subpopGuid completion:^(id __unused responseObject,
                                                                                              NSError * __unused error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (!error)
             {
                 APCLogEventWithData(@"Network Event", (@{@"event_detail":@"Reconsent email sent to User"}));
             }
             else
             {
                 NSLog(@"Did not send consent because of this error: %@",error);
                 //NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             }
             
             if (completionBlock) {completionBlock(error);}
         });
     }];
}

#pragma mark - Packaging and shipping helpers

-(void)zipEncryptAndShipInitialData:(NSDictionary *)initialData
{
    APCDataArchive *archive = [[APCDataArchive alloc] initWithReference:@"initialData"];
    //Note that contrary to documentation in AppCore, you need the file extension here to be recognized by Bridge Server
    [archive insertIntoArchive:initialData filename:@"initialData.json"];
    
    APCDataArchiveUploader *uploader = [[APCDataArchiveUploader alloc] init];
    
    //Using call from APCBaseTaskViewController here
    [uploader encryptAndUploadArchive:archive withCompletion:^(NSError *error) {
        if (! error) { NSLog(@"Encrypt/uploading followup..."); }
        else { APCLogError2(error); }
    }];
}

-(void)zipEncryptAndShipFollowupData:(NSDictionary *)followupData
{
    APCDataArchive *archive = [[APCDataArchive alloc] initWithReference:@"followup"];
    //Note that contrary to documentation in AppCore, you need the file extension here to be recognized by Bridge Server
    [archive insertIntoArchive:followupData filename:@"followup.json"];
    
    APCDataArchiveUploader *uploader = [[APCDataArchiveUploader alloc] init];
    
    //Using call from APCBaseTaskViewController here
    [uploader encryptAndUploadArchive:archive withCompletion:^(NSError *error) {
            if (! error) {
                            NSLog(@"Encrypt/uploading followup...");
            }
        else {
            APCLogError2(error);
        }
    }];
    
}

-(void)zipEncryptAndShipAllMoleMeasurementData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"measurementID" ascending:YES]];
    NSError *error = nil;
    NSArray *fetchedMeasurements = [self.context executeFetchRequest:request error:&error];
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Contains a set of all of the measurementIDs that have successfully been sent
    NSArray *immutable = ad.user.measurementsAlreadySentToBridge;
    NSMutableArray *measurementsAlreadySent = [immutable mutableCopy];
    
    for (Measurement *measurement in fetchedMeasurements)
    {
        if ([measurementsAlreadySent containsObject:measurement.measurementID])
        {
            continue; //Don't send duplicate measurements to Bridge
        }
        
        NSDictionary *measurementData = [self dictionaryForMeasurement:measurement];
        
        //Get .png file for Bridge File
        NSData *measurementPngData = [Measurement rawPngDataForMeasurement:measurement];
        
        APCDataArchive *archive = [[APCDataArchive alloc] initWithReference:@"moleMeasurement"];
        [archive insertIntoArchive:measurementData filename:@"measurementData.json"];
        [archive insertDataIntoArchive:measurementPngData filename:@"measurementPhoto.png"];
        
        APCDataArchiveUploader *uploader = [[APCDataArchiveUploader alloc] init];
        
        //Using call from APCBaseTaskViewController here
        [uploader encryptAndUploadArchive:archive withCompletion:^(NSError *error) {
            if (! error)
            {
                NSLog(@"Encrypt/uploading mole measurement for mole: %@",measurement.whichMole.moleName);
                [measurementsAlreadySent addObject:measurement.measurementID];
            }
            else { APCLogError2(error); }
        }];
    }
    //Add back the array of sent measurements in an immutable form
    NSArray *arrayWithAddedMeasurements = [NSArray arrayWithArray:measurementsAlreadySent];
    ad.user.measurementsAlreadySentToBridge = arrayWithAddedMeasurements;
}

-(void)zipEncryptAndShipRemovedMoleData:(NSDictionary *)removedMoleData
{
    APCDataArchive *archive = [[APCDataArchive alloc] initWithReference:@"removedMoleData"];
    //Note that contrary to documentation in AppCore, you need the file extension here to be recognized by Bridge Server
    [archive insertIntoArchive:removedMoleData filename:@"removedMoleData.json"];
    
    APCDataArchiveUploader *uploader = [[APCDataArchiveUploader alloc] init];
    
    //Using call from APCBaseTaskViewController here
    [uploader encryptAndUploadArchive:archive withCompletion:^(NSError *error) {
        if (! error) {
            NSLog(@"Encrypt/uploading removed mole...");
        }
        else {
            APCLogError2(error);
        }
    }];
}

-(void)zipEncryptAndShipFeedbackData:(NSDictionary *)feedbackData
{
    APCDataArchive *archive = [[APCDataArchive alloc] initWithReference:@"userFeedback"];
    //Note that contrary to documentation in AppCore, you need the file extension here to be recognized by Bridge Server
    [archive insertIntoArchive:feedbackData filename:@"userFeedback.json"];
    
    APCDataArchiveUploader *uploader = [[APCDataArchiveUploader alloc] init];
    
    //Using call from APCBaseTaskViewController here
    [uploader encryptAndUploadArchive:archive withCompletion:^(NSError *error) {
        if (! error) {
            NSLog(@"Encrypt/uploading feedback data...");
        }
        else {
            APCLogError2(error);
        }
    }];
}

//Mole Measurement Schema
/*
 moleMeasurement
 measurementData.json.zoneID - string
 measurementData.json.moleID - int
 measurementData.json.yCoordinate - float
 measurementData.json.diameter - float
 measurementData.json.dateMeasured - timestamp
 measurementData.json.xCoordinate - float
 measurementData.json.measurementID - string
 measurementPhoto.png - attachment_blob
 */
-(NSDictionary *)dictionaryForMeasurement:(Measurement *)measurement
{
    NSMutableDictionary *measurementData = [NSMutableDictionary dictionary];
    NSString *measurementUUID = [[NSUUID UUID] UUIDString];
    [measurementData setValue:measurementUUID forKey:@"measurementID"];
    [measurementData setValue:[measurement.whichMole.moleID stringValue] forKey:@"moleID"];
    [measurementData setValue:measurement.whichMole.whichZone.zoneID forKey:@"zoneID"];
    [measurementData setValue:measurement.whichMole.moleX forKey:@"xCoordinate"];
    [measurementData setValue:measurement.whichMole.moleY forKey:@"yCoordinate"];
    //NOTE THAT NSJSON SERIALIZATION CAN'T HANDLE NSDATES!!
    [measurementData setValue:[self iso8601stringFromDate:measurement.date] forKey:@"dateMeasured"];
    [measurementData setValue:measurement.absoluteMoleDiameter forKey:@"diameter"];
    return measurementData;
}

-(NSString *)iso8601stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString *iso8601String = [dateFormatter stringFromDate:date];
    return iso8601String;
}


@end
