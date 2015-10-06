//
//  AppDelegate.h
//  interfaceTesting
//
//  Created by Dan Webster on 2/24/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
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

#define numberOfDaysInFollowupPeriod 30

@end
