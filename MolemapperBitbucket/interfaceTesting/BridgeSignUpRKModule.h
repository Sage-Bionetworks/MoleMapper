//
//  BridgeSignUpRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 8/21/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "ResearchKit.h"

@interface BridgeSignUpRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

-(void)showSignUp;

@end