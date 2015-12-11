//
//  InitialSurveyRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 8/29/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface InitialSurveyRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Start up the initial demographics survey
-(void)showInitialSurvey;

@end
