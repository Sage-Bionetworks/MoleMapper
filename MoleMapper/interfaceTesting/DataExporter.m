//
//  DataExporter.m
//  MoleMapper
//
//  Created by Dan Webster on 6/20/15.
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
//**DEPRECATED** AS DATA NOT GOING TO REDCap

#define followupSurveyAPIKey @""
#define initialSurveyAPIKey @""
#define moleDataAPIKey @""

#import "DataExporter.h"
#import "AFNetworking.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Hashes.h"

@implementation DataExporter

#pragma mark - AFNetworking Calls to REDCap

-(void)postToRedCapWithFollowupData:(NSDictionary *)followupData
{
    NSMutableArray *dataArray = [NSMutableArray array];
    [dataArray addObject:followupData];
    
    //Encode your records to JSON-formatted data
    NSData *recordData = [NSJSONSerialization dataWithJSONObject:dataArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
    
    //Turn this raw data back into a human-readable string
    NSString *recordString = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
    
    NSLog(@"the following is followupData:\n%@",recordString);
    
    NSDictionary *parameters = @{
                                 @"token"   :   followupSurveyAPIKey,
                                 @"content" :   @"record",
                                 @"format"  :   @"json",
                                 @"type"    :   @"flat",
                                 @"overwriteBehavior"    :   @"normal",
                                 @"data"    :   recordString
                                 };
    
    
    //AFNetworking POST method, see AFNetworking Github page for details
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://octri.ohsu.edu/redcap/api/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *jsonFromData =
              (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingMutableContainers error:nil];
              NSLog(@"success for followup post: %@", jsonFromData);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {NSLog(@"The REDCap Error is the following: %@", error);}];
}

-(void)postToRedCapWithInitialData:(NSDictionary *)initialData
{
    NSMutableArray *dataArray = [NSMutableArray array];
    [dataArray addObject:initialData];
    
    //Encode your records to JSON-formatted data
    NSData *recordData = [NSJSONSerialization dataWithJSONObject:dataArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
    //Turn this raw data back into a human-readable string
    NSString *recordString = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
    
    NSLog(@"the following is initialData:\n%@",recordString);
    
    NSDictionary *parameters = @{
                                 @"token"   :   initialSurveyAPIKey,
                                 @"content" :   @"record",
                                 @"format"  :   @"json",
                                 @"type"    :   @"flat",
                                 @"overwriteBehavior"    :   @"normal",
                                 @"data"    :   recordString
                                 };
    
    
    //AFNetworking POST method, see AFNetworking Github page for details
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://octri.ohsu.edu/redcap/api/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *jsonFromData =
              (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingMutableContainers error:nil];
              NSLog(@"success for initial post: %@", jsonFromData);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {NSLog(@"The REDCap Error is the following: %@", error);}];
}

-(void)postToRedCapWithAllMoleData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchedMoles = [self.context executeFetchRequest:request error:&error];
    
    //Place record(s) in an array to allow potential for multiple imports
    NSMutableArray *dataArray = [NSMutableArray array];
    
    for (Mole *mole in fetchedMoles)
    {
        NSDictionary *moleDictionary = [self redcapDictionaryForMole:mole];
        [dataArray addObject:moleDictionary];
    }
    
    //Encode your records to JSON-formatted data
    NSData *recordData = [NSJSONSerialization dataWithJSONObject:dataArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
    //Turn this raw data back into a human-readable string
    NSString *recordString = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"the following is recordString:\n%@",recordString);
    
    NSDictionary *parameters = @{
                                 @"token"   :   moleDataAPIKey,
                                 @"content" :   @"record",
                                 @"format"  :   @"json",
                                 @"type"    :   @"flat",
                                 @"overwriteBehavior"    :   @"normal",
                                 @"data"    :   recordString
                                 };
    
    
    //AFNetworking POST method, see AFNetworking Github page for details
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://octri.ohsu.edu/redcap/api/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *jsonFromData =
              (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingMutableContainers error:nil];
              NSLog(@"success for mole data post: %@", jsonFromData);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {NSLog(@"The REDCap Error for mole data post is the following: %@", error);}];
}

//**Note** Can't upload multiple measurements for the same mole in the same post
-(void)postToRedCapWithAllMeasurementData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"measurementID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchedMeasurements = [self.context executeFetchRequest:request error:&error];
    
    //Place record(s) in an array to allow potential for multiple imports
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSMutableSet *molesAlreadySent = [NSMutableSet set];
    for (Measurement *measurement in fetchedMeasurements)
    {
        if ([molesAlreadySent containsObject:measurement.whichMole.moleID]) {continue;}
        NSDictionary *measurementDictionary = [self redcapDictionaryForMeasurement:measurement];
        [dataArray addObject:measurementDictionary];
        [molesAlreadySent addObject:measurement.whichMole.moleID];
    }
    
    //Encode your records to JSON-formatted data
    NSData *recordData = [NSJSONSerialization dataWithJSONObject:dataArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
    //Turn this raw data back into a human-readable string
    NSString *recordString = [[NSString alloc] initWithData:recordData encoding:NSUTF8StringEncoding];
    
    for (NSDictionary *dictionary in dataArray)
    {
        NSString *moleID = [dictionary valueForKey:@"mole_id"];
        NSLog(@"Included: %@",moleID);
    }
    //NSLog(@"the following measurements are included:\n%@",recordString);
    
    NSDictionary *parameters = @{
                                 @"token"   :   moleDataAPIKey,
                                 @"content" :   @"record",
                                 @"format"  :   @"json",
                                 @"type"    :   @"flat",
                                 @"overwriteBehavior"    :   @"normal",
                                 @"data"    :   recordString
                                 };
    
    
    //AFNetworking POST method, see AFNetworking Github page for details
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"https://octri.ohsu.edu/redcap/api/"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *jsonFromData =
              (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingMutableContainers error:nil];
              NSLog(@"success for measurement data: %@", jsonFromData);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {NSLog(@"The REDCap Error for measurement data is the following: %@", error);}];
}

-(void)postToRedCapWithAllPhotoData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"measurementID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchedMeasurements = [self.context executeFetchRequest:request error:&error];
    
    for (Measurement *measurement in fetchedMeasurements)
    {
        NSString *moleID = [self uniqueMoleIdForMole:measurement.whichMole];
        NSString *filePath = @"";
        NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filePath = [NSString stringWithFormat:@"%@/%@",docsDirectory,measurement.measurementPhoto];
        UIImage *photoImage = [UIImage imageWithContentsOfFile:filePath];
        NSData *pngData = UIImagePNGRepresentation(photoImage);
        NSDictionary *parameters = @{
                                     @"token"   :   moleDataAPIKey,
                                     @"content" :   @"file",
                                     @"action"  :   @"import",
                                     @"record"  :   moleID,
                                     @"field"   :   @"photo",
                                     @"event"   :   @"measurement_arm_2",
                                     };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFHTTPRequestOperation *op = [manager POST:@"https://octri.ohsu.edu/redcap/api/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {[formData appendPartWithFileData:pngData name:@"file" fileName:@"photo.png" mimeType:@"image/png"];}
                                           success:^(AFHTTPRequestOperation *operation, id responseObject)
                                      {NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);}
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                      {NSLog(@"Error: %@ ***** %@", operation.responseString, error);}];
        [op start];
    }
}

#pragma mark - Parameter prep
-(NSDictionary *)redcapDictionaryForMeasurement:(Measurement *)measurement
{
    NSString *measurementID = [self uniqueMeasurementIdForMeasurement:measurement];
    NSString *whichMole = [self uniqueMoleIdForMole:measurement.whichMole];
    NSString *userID = [self userID];
    NSString *diameter = [measurement.absoluteMoleDiameter stringValue];
    
    NSDictionary *moleData = @{
                               @"redcap_event_name"   : @"measurement_arm_2",
                               @"measurement_id" : measurementID,
                               @"which_mole" : whichMole,
                               @"which_user" : userID,
                               @"mole_id" : whichMole,
                               @"diameter" : diameter,
                               @"mole_measurement_data_complete": @2,
                               };
    return moleData;
}

-(NSDictionary *)redcapDictionaryForMole:(Mole *)mole
{
    NSString *zoneID = mole.whichZone.zoneID;
    NSNumber *moleXrounded = @(ceil([mole.moleX doubleValue]));
    NSString *xCoord = [moleXrounded stringValue];
    NSNumber *moleYrounded = @(ceil([mole.moleY doubleValue]));
    NSString *yCoord = [moleYrounded stringValue];
    //for uploading to redcap, need to have the unique userID in the moleID, b/c moleID is the unique key
    NSString *moleID = [self uniqueMoleIdForMole:mole];
    
    NSDictionary *moleData = @{@"redcap_event_name"   : @"mole_arm_1",
                               @"mole_id" : moleID,
                               @"user_id" : [self userID],
                               @"zone_id" : zoneID,
                               @"x_coordinate" : xCoord,
                               @"y_coordinate" : yCoord,
                               @"mole_complete": @2
                               };
    return moleData;
}

-(NSString *)uniqueMeasurementIdForMeasurement:(Measurement *)measurement
{
    NSString *userID = [self userID];
    NSString *measurementID = measurement.measurementID;
    NSString *uniqueID = [NSString stringWithFormat:@"%@|%@",measurementID,userID];
    return uniqueID;
}

//Return a moleID with the following format:userID|moleID
-(NSString *)uniqueMoleIdForMole:(Mole *)mole
{
    NSString *userID = [self userID];
    NSString *moleID = [mole.moleID stringValue];
    NSString *uniqueID = [NSString stringWithFormat:@"%@|%@",moleID,userID];
    return uniqueID;
}

#pragma mark - Helpers for ID creation
//returns the userID, which follows this: sha1hash sha1(_wom_.[firstname].[email]._wom_)
-(NSString *)userIDforFirstName:(NSString *)firstName andEmail:(NSString *)email
{
    NSString *womID = [NSString stringWithFormat:@"_wom_.%@.%@._wom_",firstName,email];
    NSString *userID = [self sha1ForString:womID];
    return userID;
}

- (NSString *)sha1ForString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

//returns the userID, which follows this: sha1hash sha1(_wom_.[firstname].[email]._wom_)
-(NSString *)userID
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *userID = [ud valueForKey:@"WOMuserID"];
    return userID;
}

@end
