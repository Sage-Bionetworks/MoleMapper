//
//  MoleViewController.h
//  
//
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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
- (void)startDemoMovie;

@property (strong, nonatomic) IBOutlet MeasuringTool *moleMeasure;
@property (strong, nonatomic) IBOutlet MeasuringTool *referenceMeasure;
@property (strong, nonatomic) MeasuringTool *selectedMeasuringTool;
@property BOOL measuringEnabled;

@property BOOL isPresentView;

@property  float oldZoomScale;

@end
