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
-(void)signInAndSendInitialData:(NSDictionary *)initialData;

//This includes the followup survey
-(void)signInAndSendFollowupData:(NSDictionary *)followupData;

//Sign in to Bridge and then send all Mole Measurements and their attendant photos
-(void)signInAndSendMeasurements;


@end
