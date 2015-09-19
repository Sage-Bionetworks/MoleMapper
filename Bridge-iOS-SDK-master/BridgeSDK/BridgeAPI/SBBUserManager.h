//
//  SBBUserManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//
//	Copyright (c) 2014-2015, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"

/*!
 * @typedef SBBUserDataShareScope
 * @brief An enumeration of the choices for the scope of sharing collected data.
 * @constant SBBUserDataSharingScopeNone The user has not consented to sharing their data.
 * @constant SBBUserDataSharingScopeStudy The user has consented only to sharing their de-identified data with the sponsors and partners of the current research study.
 * @constant SBBUserDataSharingScopeAll The user has consented to sharing their de-identified data for current and future research, which may or may not involve the same institutions or investigators.
 */
typedef NS_ENUM(NSInteger, SBBUserDataSharingScope) {
    SBBUserDataSharingScopeNone = 0,
    SBBUserDataSharingScopeStudy,
    SBBUserDataSharingScopeAll
};

/*!
 Completion block called when retrieving user profile from the API.
 
 @param userProfile By default, an SBBUserProfile object, unless the UserProfile type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBUserManagerGetCompletionBlock)(id userProfile, NSError *error);

/*!
 Completion block called when making other calls to the users API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBUserManagerCompletionBlock)(id responseObject, NSError *error);

/*!
 *  This protocol defines the interface to the SBBUserManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBUserManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 *  Fetch the UserProfile from the Bridge API.
 *
 *  @param completion An SBBUserManagerGetCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getUserProfileWithCompletion:(SBBUserManagerGetCompletionBlock)completion;

/*!
 *  Update the UserProfile to the Bridge API.
 *
 *  @param profile A client object representing the UserProfile as it should be updated.
 *  @param completion An SBBUserManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)updateUserProfileWithProfile:(id)profile completion:(SBBUserManagerCompletionBlock)completion;

/*!
 *  Add an external identifier for a participant.
 *
 *  For research studies designed to enroll participants who are tracked outside of the Bridge-specific study, you can build
 *  your application to submit a unique external identifier to the Bridge Server for that user. This can happen any time after
 *  an email address has been validated. The identifier will be exported with research data, but not with exports that provide
 *  the identities of the people in the study (like the participant roster). The identifier should be unique for the user in
 *  this study, but this is not validated by the Bridge server. The identifier can be updated, but never deleted (if absolutely
 *  necessary, set it to a "deleted" value like "N/A")
 *
 *  @param externalID An external identifier to allow this participant to be tracked outside of the Bridge-specific study.
 *  @param completion An SBBUserManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)addExternalIdentifier:(NSString *)externalID completion:(SBBUserManagerCompletionBlock)completion;

/*!
 *  Email the user's study data in the specified date range to the email address associated with their account.
 *  @param startDate The starting date for the data to be sent.
 *  @param endDate The ending date for the data to be sent.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)emailDataToUserFrom:(NSDate *)startDate to:(NSDate *)endDate completion:(SBBUserManagerCompletionBlock)completion;

/*!
 *  Change the scope of data sharing for this user.
 *  This should only be done in response to an explicit choice on the part of the user to change the sharing scope.
 *
 *  @param scope The scope of data sharing to set for this user.
 *
 *  @param completion An SBBUserManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)dataSharing:(SBBUserDataSharingScope)scope completion:(SBBUserManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge users API.
 */
@interface SBBUserManager : SBBBridgeAPIManager<SBBComponent, SBBUserManagerProtocol>

@end
