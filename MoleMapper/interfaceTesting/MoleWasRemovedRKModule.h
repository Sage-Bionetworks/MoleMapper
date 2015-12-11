//
//  MoleWasRemovedRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 9/25/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"
#import "Mole.h"

@interface MoleWasRemovedRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;
@property (strong, nonatomic) Mole *removedMole;

//Start up the initial demographics survey
-(void)showMoleRemoved;


@end
