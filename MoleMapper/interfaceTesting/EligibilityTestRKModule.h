//
//  EligibilityTestRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 10/4/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface EligibilityTestRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Start up the intro and eligibility screens adapted from ResearchKit
-(void)showEligibilityTest;

@end
