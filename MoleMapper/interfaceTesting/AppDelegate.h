//
// AppDelegate.h
//
// Created by Dan Webster on 2/24/13.
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

#import <UIKit/UIKit.h>
#import "BridgeManager.h"
#import "APCDataUploader.h"
#import "MMUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Core data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//handles data zip, encrypt, and shipping to Bridge Server
@property (strong, nonatomic) BridgeManager *bridgeManager;
@property (strong, nonatomic) APCDataUploader *dataUploader;

//name of the .pem file issues by Sage for Bridge Access
@property (strong, nonatomic) NSString *certificateFileName;

//store user data and their relevant BridgeProfile information
//securely in the keychain using APCKeyChainStore
@property (strong, nonatomic) MMUser *user;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)shouldShowOnboarding;
- (void)setOnboardingBooleansBackToInitialValues;
- (void)showWelcomeScreenWithCarousel;
- (void)showOnboarding;
- (void)showBodyMap;
- (void)showCorrectOnboardingScreenOrBodyMap;
- (void)showReconsentScreen; //specific for transition from Sage -> OHSU study host 2.0 -> 2.1

#define numberOfDaysInFollowupPeriod 30

@end
