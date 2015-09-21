//
//  MoleViewController.h
//  
//
//  Created by Dan Webster on 3/30/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Mole.h"
#import "MeasuringTool.h"
#import "StepperButton.h"
#import "NudgeButton.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import <MessageUI/MessageUI.h>
#import "CMPopTipView.h"
#import "AppDelegate.h"

//A note about the reference object and its implementation
/*
 A reference object is represented as a string that gets stored back in core data.  There is a referenceConverter
 object that is instantiated here to convert from this string to an NSNumber value (in millimeters) for the actual
 reference diameter.  Everything is represented in millimeters for the diameter, as is the custom for referring to
 mole sizes based on dermatological practice.
 */

@interface MoleViewController : UIViewController <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate,
                                                  UIScrollViewDelegate,
                                                  UIGestureRecognizerDelegate,
                                                  UITextFieldDelegate,
                                                  UIActionSheetDelegate,
                                                  MFMailComposeViewControllerDelegate,
                                                  CMPopTipViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *moleImageView;
@property (nonatomic, strong) UIImage *moleImage;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *moleName;
@property (nonatomic, strong) NSNumber *moleID;
@property (nonatomic, strong) Mole *mole;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *zoneTitle;
@property (nonatomic, strong) Measurement *measurement;

- (IBAction)openCamera:(id)sender;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTapRecognizer;

@property (weak, nonatomic) IBOutlet StepperButton *stepperDecrement;
@property (weak, nonatomic) IBOutlet StepperButton *stepperIncrement;
- (IBAction)stepperTouchDown:(StepperButton *)sender;
- (IBAction)stepperTouchDragOutside:(StepperButton *)sender;
- (IBAction)stepperTouchUpInside:(StepperButton *)sender;
- (void)updateDiameterWithChangeValue:(NSNumber *)diameterChangeValue;

@property (weak, nonatomic) IBOutlet NudgeButton *nudgeUp;
@property (weak, nonatomic) IBOutlet NudgeButton *nudgeRight;
@property (weak, nonatomic) IBOutlet NudgeButton *nudgeDown;
@property (weak, nonatomic) IBOutlet NudgeButton *nudgeLeft;
- (IBAction)nudgeTouchDown:(NudgeButton *)sender;
- (IBAction)nudgeTouchDragOutside:(NudgeButton *)sender;
- (IBAction)nudgeTouchUpInside:(NudgeButton *)sender;
- (void)updateLocationWithChangeValue:(NudgeButton *)locationChangeValue;

@property (strong, nonatomic) IBOutlet MeasuringTool *moleMeasure;
@property (strong, nonatomic) IBOutlet MeasuringTool *referenceMeasure;
@property (strong, nonatomic) MeasuringTool *selectedMeasuringTool;
@property BOOL measuringEnabled;

@property BOOL isPresentView;

@property  float oldZoomScale;

@end
