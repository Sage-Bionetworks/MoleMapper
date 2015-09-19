//
//  IntroAndEligibleRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface IntroAndEligibleRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Start up the intro and eligibility screens adapted from ResearchKit
-(void)showIntro;


@end
