//
//  FeedbackRKModule.h
//  MoleMapper
//
//  Created by Dan Webster on 10/6/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResearchKit.h"

@interface FeedbackRKModule : NSObject <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) UIViewController *presentingVC;

-(void)showFeedback;

@end
