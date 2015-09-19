//
//  FollowupSurveyRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 7/7/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "ResearchKit.h"

@interface FollowupSurveyRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;
@property (strong, nonatomic) NSNumber *numberOfDaysBetweenFollowups;

//Will return whether it has been 30 days since the last survey was taken
-(BOOL)shouldShowFollowupSurvey;

-(void)showSurvey;


@end
