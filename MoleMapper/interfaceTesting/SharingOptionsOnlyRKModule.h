//
//  SharingOptionsOnlyRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 9/15/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface SharingOptionsOnlyRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

//Show the Sharing Options again
-(void)showSharing;


@end
