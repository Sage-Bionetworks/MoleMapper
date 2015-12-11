//
//  OnboardingViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 8/10/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Serves as a 'launch pad' view controller from which to host the ResearchKit Modules
 */
@interface OnboardingViewController : UIViewController

-(void)showIneligibleForStudy;

-(void)showEligibleForStudy;

-(void)showQuiz;

@end
