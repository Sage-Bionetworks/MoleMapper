//
//  ComparisonPageViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 10/29/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import <MessageUI/MessageUI.h>

//A view controller that serves to hold the page view containing MeasurementComparisonViewControllers
//and control the retrieval of the MoleMeasurement Data

@interface ComparisonPageViewController : UIViewController <UIPageViewControllerDataSource,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Mole *mole;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *moleMeasurements;
@property (strong, nonatomic) UIPageViewController *pageController;

@end
