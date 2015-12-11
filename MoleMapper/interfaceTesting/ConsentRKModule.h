//
//  ConsentRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 8/11/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface ConsentRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Start up the consent process
-(void)showConsent;


@end
