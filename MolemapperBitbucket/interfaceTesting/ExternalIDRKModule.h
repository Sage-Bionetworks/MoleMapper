//
//  ExternalIDRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 9/17/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface ExternalIDRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

-(void)showExternalID;


@end
