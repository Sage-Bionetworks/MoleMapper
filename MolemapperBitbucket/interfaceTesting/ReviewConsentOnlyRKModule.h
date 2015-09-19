//
//  ReviewConsentOnlyRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface ReviewConsentOnlyRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Show the Consent Review again
-(void)showConsentReview;


@end
