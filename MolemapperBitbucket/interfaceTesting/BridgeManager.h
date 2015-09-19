//
//  BridgeManager.h
//  MoleMapper
//
//  Created by Dan Webster on 8/19/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCDataArchive.h"
#import <BridgeSDK/BridgeSDK.h>
#import "SBBUserProfile+MoleMapper.h"

@interface BridgeManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

//Sends consent information such as signature, sharing scope
- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock;

- (void) updateProfileOnCompletion:(void (^)(NSError *))completionBlock;

//This includes the consent data and initial survey/demographic info or the followup survey data
-(void)zipEncryptAndShipInitialData:(NSDictionary *)initialData;

//This includes the followup survey
-(void)zipEncryptAndShipFollowupData:(NSDictionary *)followupData;

//This includes the mole measurements and their attendant photos
-(void)zipEncryptAndShipAllMoleMeasurementData;

@end
