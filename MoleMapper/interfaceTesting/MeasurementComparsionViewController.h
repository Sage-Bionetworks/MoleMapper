//
//  MeasurementComparsionViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 10/29/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import <MessageUI/MessageUI.h>

@interface MeasurementComparsionViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property int index;
@property (strong, nonatomic) UIScrollView *measurementScrollView;
@property (nonatomic, strong) UIImageView *measurementImageView;
@property (nonatomic, strong) UIImage *measurementImage;
@property Measurement *moleMeasurement;

@end
