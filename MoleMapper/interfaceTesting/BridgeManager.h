//
//  BridgeManager.h
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


#import <Foundation/Foundation.h>
#import "APCDataArchive.h"
#import <BridgeSDK/BridgeSDK.h>
#import "SBBUserProfile+MoleMapper.h"

@interface BridgeManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

-(void)signInAndChangeSharingToScope:(NSNumber *)sharingScope;

//Sends consent information such as signature, sharing scope
- (void)sendUserConsentedToBridgeOnCompletion:(void (^)(NSError *))completionBlock;

- (void) updateProfileOnCompletion:(void (^)(NSError *))completionBlock;

//This includes the consent data and initial survey/demographic info or the followup survey data
-(void)signInAndSendInitialData:(NSDictionary *)initialData;

//This includes the followup survey
-(void)signInAndSendFollowupData:(NSDictionary *)followupData;

//Sign in to Bridge and then send all Mole Measurements and their attendant photos
-(void)signInAndSendMeasurements;

//Sign in to Bridge and then send diagnosis information about removed moles
-(void)signInAndSendRemovedMoleData:(NSDictionary *)removedMoleData;

//Sign in to Bridge and then send feedback information about removed moles
-(void)signInAndSendFeedback:(NSDictionary *)feedbackData;

//Sign in to Bridge and then send consent document to users in group
-(void)signInAndReEmailConsentDocForSubpopulation:(nonnull NSString *)subpopGuid andCompletionBlock:( void ( ^ _Nullable )( NSError * _Nullable ))completionBlock;


@end
