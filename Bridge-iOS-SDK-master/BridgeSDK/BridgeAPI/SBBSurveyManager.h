//
//  SBBSurveyManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
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
#import "SBBSurvey.h"

/*!
 Completion block called when retrieving a survey from the API.
 
 @param survey By default, an SBBSurvey object, unless the Survey type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetCompletionBlock)(id survey, NSError *error);

/*!
 Completion block called when submitting answers to a survey to the API.
 
 @param identifierHolder By default, an SBBIdentifierHolder object, unless the IdentifierHolder type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:. The identifier in question is the identifier of the SurveyResponse object created by submitting this set of answers, which can be used to later amend or delete the answers to this instance of taking the survey.
 @param error            An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerSubmitAnswersCompletionBlock)(id identifierHolder, NSError *error);

/*!
 Completion block called when retrieving a survey response from the API.
 
 @param surveyResponse By default, an SBBSurveyResponse object, unless the SurveyResponse type has been mapped in SBBObjectManager setupMappingForType:toClass:fieldToPropertyMappings:
 @param error       An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerGetResponseCompletionBlock)(id surveyResponse, NSError *error);

/*!
 Completion block called when updating or deleting a survey response to the API.
 
 @param responseObject JSON response from the server.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBSurveyManagerEditResponseCompletionBlock)(id responseObject, NSError *error);

/*!
 *  This protocol defines the interface to the SBBSurveyManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBSurveyManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 Fetch a survey from the Bridge API via an activityRef (href).
 
 @param ref        The href identifying the desired survey, obtained e.g. from the Schedules or Activities API.
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion;

/*!
 Fetch a survey from the Bridge API by guid and version number.
 
 @param guid       The survey's guid.
 @param createdOn    The creation date and time of the version of the survey to fetch.
 @param completion An SBBSurveyManagerGetCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion;

/*!
 Submit a set of answers to a survey specified by an SBBSurvey object.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param survey           The SBBSurveyObject representing the survey being answered, obtained e.g. from one of the getSurveyBy... methods of this manager.
 @param completion    An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The identifierHolder passed in contains an identifier assigned by the server to the survey response created by submitting these answers.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurvey:(SBBSurvey *)survey completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Submit a set of answers to a survey specified by an SBBSurvey object, and specify an identifier for the SurveyResponse object to create as a result.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param survey        The SBBSurveyObject representing the survey being answered, obtained e.g. from one of the getSurveyBy... methods of this manager.
 @param identifier    An identifier to use for the SurveyResponse created as a result of submitting these answers. If nil, this behaves the same as calling submitAnswers:toSurveyByRef:completion:.
 @param completion    An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The identifierHolder passed in contains the identifier of the survey response created by submitting these answers, which will match what you sent in the identifier parameter (unless you sent nil).
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurvey:(SBBSurvey *)survey withResponseIdentifier:(NSString *)identifier completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Submit a set of answers to a survey by the survey's guid and version number.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param guid       The survey's guid.
 @param createdOn    The creation date and time of the version of the survey being answered.
 @param completion An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The guidHolder passed in contains the guid of the survey response created by submitting these answers.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Submit a set of answers to a survey by the survey's guid and version number, and specify an identifier for the SurveyResponse object to create.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param surveyGuid    The survey's guid.
 @param createdOn     The creation date and time of the version of the survey being answered.
 @param responseIdentifier  An identifier to use for the SurveyResponse created as a result of submitting these answers. If nil, this behaves the same as calling submitAnswers:toSurveyByGuid:createdOn:completion:.
 @param completion    An SBBSurveyManagerSubmitAnswersCompletionBlock to be called upon completion. The identifierHolder passed in contains the identifier of the survey response created by submitting these answers, which will match what you sent in the identifier parameter (unless you sent nil).
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)surveyGuid createdOn:(NSDate *)createdOn withResponseIdentifier:(NSString *)responseIdentifier completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion;

/*!
 Fetch a previously-started survey response from the Bridge API.
 
 @param identifier The identifier of the desired survey response.
 @param completion An SBBSurveyManagerGetResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)getSurveyResponse:(NSString *)identifier completion:(SBBSurveyManagerGetResponseCompletionBlock)completion;

/*!
 Add answers to an existing survey response.
 
 @param surveyAnswers An NSArray of survey answer objects for the questions answered.
 @param guid          The survey response's guid.
 @param completion    An SBBSurveyManagerEditResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)addAnswers:(NSArray *)surveyAnswers toSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion;

/*!
 Delete an existing survey response.
 
 @param guid          The survey response's guid.
 @param completion    An SBBSurveyManagerEditResponseCompletionBlock to be called upon completion.
 
 @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)deleteSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge surveys API.
 */
@interface SBBSurveyManager : SBBBridgeAPIManager<SBBComponent, SBBSurveyManagerProtocol>

@end
