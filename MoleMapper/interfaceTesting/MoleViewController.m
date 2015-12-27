//
//  MoleViewController.m
//
//  Created by Dan Webster on 3/30/13.
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


#import "MoleViewController.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import "Mole+MakeAndMod.h"
#import "UIImage+Extras.h"
#import "Measurement+MakeAndMod.h"
#import "Measurement.h"
#import "ComparisonPageViewController.h"
#import "VariableStore.h"
#import "ScaledImageView.h"
#import "ReferenceSetterViewController.h"
#import "ReferenceConverter.h"
#import "AppDelegate.h"
#import "HelpMovieViewController.h"
#import "CMPopTipView.h"
#import "KLCPopup.h"
#import "ResearchKit.h"
#import "MoleWasRemovedRKModule.h"
#import "Zone+MakeAndMod.h"
#import "DemoKLCPopupHelper.h"
#import "DashboardViewController.h"
#import "DashboardModel.h"

@interface MoleViewController ()
{
    VariableStore *vars;
}

@property CGPoint refMeasureCenter;
@property (nonatomic, weak) IBOutlet UITextField *moleNameTextField;
@property (nonatomic, weak) IBOutlet UIButton *currentReference;
@property (nonatomic, weak) IBOutlet UITextField *moleSizeField;
@property (nonatomic, strong) CMPopTipView *popTipViewDemoButton;
@property (nonatomic, strong) CMPopTipView *popTipViewComparison;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *compareButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *demoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property BOOL shouldShowVideoPopup;
@property BOOL shouldShowExamplePopup;

@property (nonatomic, strong) MoleWasRemovedRKModule *removed;

//Will take strings from the reference field and convert to an absolute diameter (in millimeters)
@property (nonatomic, strong) ReferenceConverter *refConverter;

@end

@implementation MoleViewController
@synthesize context;
@synthesize moleName;
@synthesize moleID;

#pragma mark - Setters and Getters

-(UIImage *)moleImage
{
    UIImage *rawImage;
    if (!_moleImage)
    {
        rawImage = [Measurement imageForMeasurement:self.measurement];
        CGImageRef cgref = [rawImage CGImage];
        CIImage *cim = [rawImage CIImage];
        if (cim == nil && cgref == NULL)
        {
            //if nothing from core data, then load up the default
            rawImage = [UIImage imageNamed:@"measurementNoPhoto.png"];
        }
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    _moleImage = [rawImage imageByScalingProportionallyToSize:CGSizeMake(screenWidth, screenHeight)];

    return _moleImage;
}

-(UIImageView *)moleImageView
{
    if (!_moleImageView) _moleImageView = [[UIImageView alloc] initWithImage:self.moleImage];
    _moleImageView.userInteractionEnabled = YES;
    return _moleImageView;
}

//Converts the text which is user-friendly (has ' mm' for a label, etc) and converts to standard nomenclature recognized by Core Data
-(ReferenceConverter *)refConverter
{
    if (!_refConverter)
    {
        _refConverter = [[ReferenceConverter alloc] init];
    }
    return _refConverter;
}

//By default, the absolute reference diameter is set to that of a dime

#pragma mark - ViewController Life Cycle

- (IBAction)closeViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.shouldShowVideoPopup = YES;
    self.shouldShowExamplePopup = YES;
    
    if (_isPresentView)
    {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(closeViewController)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
        [barButtonItem setTarget:self];
        [barButtonItem setAction:@selector(closeViewController:)];
        //_isPresentView = NO;
    }

    NSNumber *zoneID = [NSNumber numberWithInt:[self.mole.whichZone.zoneID intValue]];
    self.navigationItem.title = [Zone zoneNameForZoneID:zoneID];
    self.automaticallyAdjustsScrollViewInsets = YES;
    vars = [VariableStore sharedVariableStore];
    vars.moleViewStepperIncrement = self.stepperIncrement;
    [self.stepperIncrement loadImagesForButton:self.stepperIncrement withViewController:self];
    vars.moleViewStepperDecrement = self.stepperDecrement;
    [self.stepperDecrement loadImagesForButton:self.stepperDecrement withViewController:self];
    
    vars.moleViewNudgeUp = self.nudgeUp;
    [self.nudgeUp loadImagesForButton:self.nudgeUp withViewController:self];
    vars.moleViewNudgeRight = self.nudgeRight;
    [self.nudgeRight loadImagesForButton:self.nudgeRight withViewController:self];
    vars.moleViewNudgeDown = self.nudgeDown;
    [self.nudgeDown loadImagesForButton:self.nudgeDown withViewController:self];
    vars.moleViewNudgeLeft = self.nudgeLeft;
    [self.nudgeLeft loadImagesForButton:self.nudgeLeft withViewController:self];
    
    _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moleImageDoubleTapped:)];
	[_doubleTapRecognizer setNumberOfTapsRequired:2];
	[_doubleTapRecognizer setDelegate:self];
	[self.moleImageView addGestureRecognizer:_doubleTapRecognizer];
    
    _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moleImageSingleTapped:)];
	[_singleTapRecognizer setNumberOfTapsRequired:1];
    [_singleTapRecognizer requireGestureRecognizerToFail: _doubleTapRecognizer];
	[_singleTapRecognizer setDelegate:self];
	[self.moleImageView addGestureRecognizer:_singleTapRecognizer];
    
    [self.scrollView addSubview:self.moleImageView];
    [self.scrollView addSubview:self.moleNameTextField];
    [self.scrollView addSubview:self.currentReference];
    [self.scrollView addSubview:self.moleSizeField];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 10.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.moleImageView.frame.size;  // Tell the scrollView how big its subview is
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.oldZoomScale = self.scrollView.zoomScale;
    
    self.moleNameTextField.delegate = self;
    self.moleNameTextField.text = self.mole.moleName;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Must take into account changes in the reference that may have just been set in ReferenceSetterViewController
    //Will always have a non-nil value because AppDelegate sets to the default of "Dime" and nil value not allowed in custom reference setter
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [self updateReferenceFieldWithReference:[standardUserDefaults objectForKey:@"referenceObject"]];
    
    //Pull most recent measurement for this mole based on date of creation (initiated when the photo is taken)
    self.measurement = [Measurement getMostRecentMoleMeasurementForMole:self.mole withContext:self.context];
    
    //Note: even if just taking a picture with the camera, a default measurement will be put in core data and saved
    if (self.measurement)
    {
        [self updateReferenceFieldWithReference:self.measurement.referenceObject];
        [self createMeasurementToolsWithMeasurment:self.measurement];
        [self updateMoleSizeFromCurrentMeasurement];
    }
    else
    {
        self.moleSizeField.text = @"Mole Size: N/A";
        //Don't make any measurement tools if no measurement
    }
    
    self.selectedMeasuringTool = self.moleMeasure;
    //[self deselectMeasuringTools];
    [self selectMeasuringTool:self.selectedMeasuringTool];
    
    self.navigationItem.hidesBackButton=YES;
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Done"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(backButtonAction:)];
    //self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    [self.navigationItem setLeftBarButtonItem:btnBack];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", self.mole];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    if ([matches count] == 0)
    {
        self.compareButton.enabled = NO;
        self.exportButton.enabled = NO;
        self.settingsButton.enabled = NO;
    }
    else if ([matches count] == 1)
    {
        self.compareButton.enabled = NO;
        self.exportButton.enabled = YES;
        self.settingsButton.enabled = YES;
    }
    else
    {
        self.compareButton.enabled = YES;
        self.exportButton.enabled = YES;
        self.settingsButton.enabled = YES;
    }

}

-(void) backButtonAction:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //You are about to leave after your first measurement
    if ([ud objectForKey:@"showDemoInfo"] == [NSNumber numberWithBool:YES] && self.measurement)
    {
        [self showMonitorPopup:self];
    }
    else
    {
        if (_isPresentView) {[self closeViewController:self];}
        else {[self.navigationController popViewControllerAnimated:YES];}
    }
    
}

//If you need to do any calculations based on the subviews having been laid out (like the measurement tools) do it below
-(void)viewDidAppear:(BOOL)animated
{
    [self updateMoleSizeFromOnScreenMeasurementTools];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"showDemoInfo"] == [NSNumber numberWithBool:YES] && !self.measurement)
    {
        [self showMeasurePopup:self];
        //[self showPopTipViewDemoButton];
        //self.shouldShowVideoPopup = NO;
    }
    if ([ud objectForKey:@"showDemoInfo"] == [NSNumber numberWithBool:YES] && self.measurement && self.shouldShowExamplePopup)
    {
        [self showExamplePopup:self];
    }
}

//Save any changes to measurements upon leaving the screen, then clear all measurement-related properties
-(void)viewWillDisappear:(BOOL)animated
{
    //Provided that you have a non-blank string in the UITextField, update the mole name before transitioning away
    if (![self.moleNameTextField.text isEqualToString:@""])
    {
        self.mole.moleName = self.moleNameTextField.text;
        
        //With the moleName changed, sync this back to persistance mole storage
        [Mole moleWithMoleID:self.mole.moleID
                withMoleName:self.mole.moleName
                     atMoleX:self.mole.moleX
                     atMoleY:self.mole.moleY
                      inZone:self.mole.whichZone
      inManagedObjectContext:self.context];
    }
    [self saveMeasurementData];
    if (self.measurement)
    {
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [ad.bridgeManager signInAndSendMeasurements];
    }
    //_isPresentView = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    //clear out existing data to allow for a reset upon coming back from another view
    //self.measurement = nil;
    [self.moleImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.moleImage = nil;
    [self.popTipViewDemoButton dismissAnimated:YES];
}

#pragma mark - PopTip View

-(void)showPopTipViewDemoButton
{
    NSString *message = @"How to measure\nyour moles";
    self.popTipViewDemoButton = [[CMPopTipView alloc] initWithMessage:message];
    self.popTipViewDemoButton.delegate = self;
    self.popTipViewDemoButton.delegate = self;
    self.popTipViewDemoButton.backgroundColor = [UIColor whiteColor];
    self.popTipViewDemoButton.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.popTipViewDemoButton.borderWidth = 1.0;
    self.popTipViewDemoButton.has3DStyle = NO;
    self.popTipViewDemoButton.hasShadow = NO;
    self.popTipViewDemoButton.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    self.popTipViewDemoButton.titleFont = [UIFont systemFontOfSize:14.0 weight:0.5];
    [self.popTipViewDemoButton presentPointingAtBarButtonItem:self.demoButton animated:YES];
}

-(void)showPopTipViewComparison
{
    if (self.popTipViewComparison)
    {
        [self.popTipViewComparison dismissAnimated:YES];
    }
    else
    {
        NSString *message = @"Compare to previous\nmeasurements if you\nhave more than 1";
        self.popTipViewComparison = [[CMPopTipView alloc] initWithMessage:message];
        self.popTipViewComparison.delegate = self;
        [self.popTipViewComparison presentPointingAtBarButtonItem:self.compareButton animated:YES];
    }
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    // User can tap CMPopTipView to dismiss it
    popTipView = nil;
}

-(void)dismissAllPopTipViews
{
    [self.popTipViewDemoButton dismissAnimated:YES];
    [self.popTipViewComparison dismissAnimated:YES];
}

#pragma mark - KLCPopup

-(void)showRememberCoinPopup:(id)sender
{
    // Generate content view to present
    UIView* contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 12.0;
    
    UILabel* welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    welcomeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.textColor = [UIColor blackColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.font = [UIFont systemFontOfSize:16.0];
    welcomeLabel.text = @"Don't forget to include a reference like a coin in the measurement photo";
    
    UIImageView *demoShot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photoOfMole"]];
    UIColor *mmBlue = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:1.0 alpha:1.0];
    
    
    APCButton *nextButton = [DemoKLCPopupHelper buttonForDemoWithColor:mmBlue
                                                             withLabel:@"Got it"
                                                        withEdgeInsets:UIEdgeInsetsMake(12, 50, 12, 50)];
    [nextButton addTarget:self action:@selector(gotItButtonPressedMeasure:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *demoOffButton = [DemoKLCPopupHelper demoOffButtonWithColor:mmBlue withLabel:@"Turn Off Demonstration"];
    [demoOffButton addTarget:self action:@selector(noMoreRemidersPressedMeasure:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:welcomeLabel];
    [contentView addSubview:demoShot];
    [contentView addSubview:demoOffButton];
    [contentView addSubview:nextButton];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, nextButton, demoShot, demoOffButton, welcomeLabel);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[demoShot]-(16)-[welcomeLabel]-(16)-[nextButton]-(10)-[demoOffButton]-(5)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[welcomeLabel]-(10)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:(KLCPopupShowType)KLCPopupShowTypeGrowIn
                                         dismissType:(KLCPopupDismissType)KLCPopupDismissTypeShrinkOut
                                            maskType:(KLCPopupMaskType)KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    
    [popup show];
}

// Tap Video to watch an example measurement

- (void)showMeasurePopup:(id)sender
{
    UIView *contentView = [DemoKLCPopupHelper contentViewForDemo];
    NSString *headerText = @"Step 2: Measure it";
    NSString *descriptionText = @"Take a close-up photo of one mole next to a reference item like a coin";
    UILabel *header = [DemoKLCPopupHelper labelForDemoWithFontSize:24.0 andText:headerText];
    UILabel *description = [DemoKLCPopupHelper labelForDemoWithFontSize:16.0 andText:descriptionText];
    UIImageView *demoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demoMeasureMovie"]];
    UIColor *mmBlue = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:1.0 alpha:1.0];
    //UIColor *mmRed = [UIColor colorWithRed:(225.0/255.0) green:(25.0/255.0) blue:(25.0/255.0) alpha:0.75];
    
    APCButton *nextButton = [DemoKLCPopupHelper buttonForDemoWithColor:mmBlue
                                                             withLabel:@"Next"
                                                        withEdgeInsets:UIEdgeInsetsMake(10, 50, 10, 50)];
    UIButton *demoOffButton = [DemoKLCPopupHelper demoOffButtonWithColor:mmBlue withLabel:@"Turn Off Demonstration"];
    
    [nextButton addTarget:self action:@selector(nextButtonPressedMeasure:) forControlEvents:UIControlEventTouchUpInside];
    [demoOffButton addTarget:self action:@selector(demoOffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:header];
    [contentView addSubview:description];
    [contentView addSubview:demoImage];
    [contentView addSubview:demoOffButton];
    [contentView addSubview:nextButton];
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, header, nextButton, demoImage, demoOffButton, description);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[demoImage]-(0)-[header]-(10)-[description]-(10)-[nextButton]-(10)-[demoOffButton]-(5)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[description]-(10)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:(KLCPopupShowType)KLCPopupShowTypeSlideInFromRight
                                         dismissType:(KLCPopupDismissType)KLCPopupDismissTypeSlideOutToLeft
                                            maskType:(KLCPopupMaskType)KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    
    [popup show];
}

- (void)showExamplePopup:(id)sender
{
    UIView *contentView = [DemoKLCPopupHelper contentViewForDemo];
    NSString *headerText = @"Step 2: Measure it";
    NSString *descriptionText = @"Move and re-size the measurement tools so that the red circles are around the mole and the reference item";
    UILabel *header = [DemoKLCPopupHelper labelForDemoWithFontSize:24.0 andText:headerText];
    UILabel *description = [DemoKLCPopupHelper labelForDemoWithFontSize:16.0 andText:descriptionText];
    UIImageView *demoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demoExample"]];
    UIColor *mmBlue = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:1.0 alpha:1.0];
    //UIColor *mmRed = [UIColor colorWithRed:(225.0/255.0) green:(25.0/255.0) blue:(25.0/255.0) alpha:0.75];
    
    APCButton *nextButton = [DemoKLCPopupHelper buttonForDemoWithColor:mmBlue
                                                             withLabel:@"Next"
                                                        withEdgeInsets:UIEdgeInsetsMake(10, 50, 10, 50)];
    
    APCButton *watchAnExampleButton = [DemoKLCPopupHelper buttonForDemoWithColor:mmBlue
                                                             withLabel:@"Watch an Example"
                                                        withEdgeInsets:UIEdgeInsetsMake(10, 25, 10, 25)];
    
    UIButton *demoOffButton = [DemoKLCPopupHelper demoOffButtonWithColor:mmBlue withLabel:@"Turn Off Demonstration"];
    
    [nextButton addTarget:self action:@selector(nextButtonPressedExample:) forControlEvents:UIControlEventTouchUpInside];
    [watchAnExampleButton addTarget:self action:@selector(watchAnExamplePressed:) forControlEvents:UIControlEventTouchUpInside];
    [demoOffButton addTarget:self action:@selector(demoOffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:header];
    [contentView addSubview:description];
    [contentView addSubview:demoImage];
    [contentView addSubview:watchAnExampleButton];
    [contentView addSubview:nextButton];
    [contentView addSubview:demoOffButton];
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, header, nextButton, demoImage, watchAnExampleButton, description, demoOffButton);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[demoImage]-(0)-[header]-(10)-[description]-(10)-[watchAnExampleButton]-(10)-[nextButton]-(10)-[demoOffButton]-(5)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[description]-(10)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:(KLCPopupShowType)KLCPopupShowTypeSlideInFromRight
                                         dismissType:(KLCPopupDismissType)KLCPopupDismissTypeSlideOutToLeft
                                            maskType:(KLCPopupMaskType)KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    
    [popup show];
}


- (void)showMonitorPopup:(id)sender
{
    UIView *contentView = [DemoKLCPopupHelper contentViewForDemo];
    NSString *headerText = @"Step 3: Monitor it";
    NSString *descriptionText = @"Monitor this mole by re-measuring it once a month.\n\nCheck the dashboard to see your progress and mole statistics";
    UILabel *header = [DemoKLCPopupHelper labelForDemoWithFontSize:24.0 andText:headerText];
    UILabel *description = [DemoKLCPopupHelper labelForDemoWithFontSize:16.0 andText:descriptionText];
    UIImageView *demoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"demoMonitor"]];
    UIColor *mmBlue = [UIColor colorWithRed:0.0 green:(122.0/255.0) blue:1.0 alpha:1.0];
    //UIColor *mmRed = [UIColor colorWithRed:(225.0/255.0) green:(25.0/255.0) blue:(25.0/255.0) alpha:0.75];
    
    APCButton *nextButton = [DemoKLCPopupHelper buttonForDemoWithColor:mmBlue
                                                             withLabel:@"Dashboard"
                                                        withEdgeInsets:UIEdgeInsetsMake(10, 26, 10, 26)];
    
    [nextButton addTarget:self action:@selector(nextButtonPressedMonitor:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:header];
    [contentView addSubview:description];
    [contentView addSubview:demoImage];
    [contentView addSubview:nextButton];
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, header, nextButton, demoImage, description);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[demoImage]-(0)-[header]-(10)-[description]-(10)-[nextButton]-(10)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[description]-(10)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:(KLCPopupShowType)KLCPopupShowTypeSlideInFromRight
                                         dismissType:(KLCPopupDismissType)KLCPopupDismissTypeSlideOutToLeft
                                            maskType:(KLCPopupMaskType)KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:NO
                               dismissOnContentTouch:NO];
    
    [popup show];
}

- (void)gotItButtonPressedMeasure:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    [self openCameraDirectlyWithoutPopup];
}

- (void)noMoreRemidersPressedMeasure:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSNumber numberWithBool:NO] forKey:@"shouldShowRememberCoinPopup"];
    [self openCameraDirectlyWithoutPopup];
}

- (void)nextButtonPressedMeasure:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    //[self performSelector:@selector(startDemoMovie) withObject:self afterDelay:0.4];
}

-(void)nextButtonPressedExample:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
}

-(void)watchAnExamplePressed:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    [self performSelector:@selector(startDemoMovie) withObject:self afterDelay:0.4];
}

- (void)nextButtonPressedMonitor:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSNumber numberWithBool:NO] forKey:@"showDemoInfo"];

    [self popToDashboardAtIndex:1];
}

-(void)popToDashboardAtIndex:(NSInteger)index;
{
    DashboardViewController * target = [[self.tabBarController viewControllers] objectAtIndex:index];
    [target.navigationController popToRootViewControllerAnimated: YES];
    [self.tabBarController setSelectedIndex:index];
}

-(void)startDemoMovie
{
    self.shouldShowExamplePopup = NO;
    [self performSegueWithIdentifier:@"segueToHelp" sender:self];
}

- (void)demoOffButtonPressed:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSNumber numberWithBool:NO] forKey:@"showDemoInfo"];
    [self popToDashboardAtIndex:0];
}

- (void)fieldCancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSNumber numberWithBool:NO] forKey:@"showDemoInfo"];
}

#pragma mark - Measurement Tool Creation Helpers

-(void)createDefaultMeasurementTools
{
    CGPoint scrCtr = [vars locationOfScreenCenterOnScrollView:self.scrollView atScale:self.scrollView.zoomScale];
    CGPoint location;
    location = CGPointMake(scrCtr.x - 40.0, scrCtr.y - 70.0);
    self.referenceMeasure = [[MeasuringTool alloc] initWithType:MeasuringToolTypeReferenceMeasure
                                                    andDiameter:MeasuringToolDiameterDefault
                                                     atLocation:location
                                               onViewController:self
                                                        andView:_moleImageView
                                                  andScrollView:self.scrollView];
    
    location = CGPointMake(scrCtr.x + 40.0, scrCtr.y + 70.0);
    self.moleMeasure = [[MeasuringTool alloc] initWithType:MeasuringToolTypeMoleMeasure
                                               andDiameter:(MeasuringToolDiameterDefault / 8)
                                                atLocation:location
                                          onViewController:self
                                                   andView:_moleImageView
                                             andScrollView:self.scrollView];
    
    [self selectMeasuringTool:self.referenceMeasure];
    [self selectMeasuringTool:self.moleMeasure];
}

-(void)createMeasurementToolsWithMeasurment:(Measurement *)measurement
{
    CGPoint measurementLocation = CGPointMake([measurement.measurementX floatValue],[measurement.measurementY floatValue]);
    CGPoint referenceLocation = CGPointMake([measurement.referenceX floatValue],[measurement.referenceY floatValue]);
    
    self.moleMeasure = [[MeasuringTool alloc] initWithType:MeasuringToolTypeMoleMeasure
                                               andDiameter:[measurement.measurementDiameter floatValue]
                                                atLocation:measurementLocation
                                          onViewController:self
                                                   andView:_moleImageView
                                             andScrollView:self.scrollView];
    
    self.referenceMeasure = [[MeasuringTool alloc] initWithType:MeasuringToolTypeReferenceMeasure
                                                    andDiameter:[measurement.referenceDiameter floatValue]
                                                     atLocation:referenceLocation
                                               onViewController:self
                                                        andView:_moleImageView
                                                  andScrollView:self.scrollView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.moleImageView;
}

#pragma mark - MFMailComposeViewController Delegate Methods
//Notes for this implementation found here: http://www.appcoda.com/ios-programming-101-send-email-iphone-app/

- (IBAction)showEmail:(id)sender
{
    //HAVE TO SAVE TO CORE DATA HERE BECAUSE VIEWWILLDISAPPEAR SAVE HASN"T HAPPENED YET
    [self saveMeasurementData];
    NSString *emailTitle = [self emailTitleForMeasurement:self.measurement];
    NSString *messageBody = [self emailBodyForMeasurement:self.measurement];
    NSArray *toRecipents = [NSArray arrayWithObject:[self recipientForEmail]];
    //NSString *filePath = [Measurement ] self.measurement.measurementID;
    //NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSData *fileData = [Measurement rawPngDataForMeasurement:self.measurement];
    NSString *mimeType = @"image/png";
    NSString *fileName = @"filename";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc)
    {
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [mc addAttachmentData:fileData mimeType:mimeType fileName:fileName];
    
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

-(NSString *)emailTitleForMeasurement:(Measurement *)measurement
{
    NSString *title = [NSString stringWithFormat:@"[Mole Mapper] %@",self.mole.moleName];
    return title;
}

-(NSString *)emailBodyForMeasurement:(Measurement *)measurement
{
    NSString *moleData = [NSString stringWithFormat:@"Mole Name: %@\n",self.mole.moleName];
    NSNumber *zoneID = @([self.mole.whichZone.zoneID intValue]);
    NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
    NSString *zoneData = [NSString stringWithFormat:@"Body Map Zone: %@\n",zoneName];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", self.mole];
    NSError *error = nil;
    NSArray *measurementsSortedByDate = [self.context executeFetchRequest:request error:&error];
    
    NSString *measurementList = [NSString stringWithFormat:@"Measurement(s) taken:\n"];
    for (Measurement *measurement in measurementsSortedByDate)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
        
        NSString *stringFromDate = [formatter stringFromDate:measurement.date];
        stringFromDate = [stringFromDate stringByAppendingString:@": "];
        float roundedDiameter = [[DashboardModel sharedInstance] correctFloat:[measurement.absoluteMoleDiameter floatValue]];
        NSString* formattedSize = [NSString stringWithFormat:@"%.1f",roundedDiameter];
        stringFromDate = [stringFromDate stringByAppendingString:formattedSize];
        stringFromDate = [stringFromDate stringByAppendingString:@" mm\n"];
        measurementList = [measurementList stringByAppendingString:stringFromDate];
    }
    NSString *attachmentNotice = [NSString stringWithFormat:@"\n[Most recent photo of %@ Attached]\n",self.mole.moleName];
    //NSString *postScript = @"To auto-populate these emails with your email address, please go to Settings in the Menu screen.\n\nFor older photos of this mole, please export from the comparison screen.";
    NSString *body = [NSString stringWithFormat:@"%@%@%@%@",moleData,zoneData,measurementList,attachmentNotice];//,postScript];
    return body;
}

-(NSString *)recipientForEmail
{
    NSString *emailRecipient = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *recipientFromUserDefaults = [standardUserDefaults valueForKey:@"emailForExport"];
    if (recipientFromUserDefaults) {emailRecipient = recipientFromUserDefaults;}
    return emailRecipient;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Camera Operation and Photo Storage

- (IBAction)openCamera:(UIBarButtonItem *)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"shouldShowRememberCoinPopup"] == YES || [ud boolForKey:@"showDemoInfo"] == YES)
    {
        [self showRememberCoinPopup:self];
    }
    else
    {
        [self launchCameraControllerFromViewController:self usingDelegate:self];
    }
}

-(void)openCameraDirectlyWithoutPopup
{
    [self launchCameraControllerFromViewController:self usingDelegate:self];
}

//Note this is coming from http://www.instructables.com/id/How-to-use-the-camera-in-your-iOS-program/step3/launchCameraController/
-(BOOL)launchCameraControllerFromViewController: (UIViewController *) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    BOOL truefalse = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]; //variable to check whether there is a camera available
    //if there is a camera, the delegate passed exists, and the controller passed exists, proceed on, otherwise don't go any further
    if (!truefalse || (delegate == nil) || (controller == nil)) {
        NSLog(@"no can do, delegate/camera/view controller doesn't exist!");
        return NO;
    }
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    cameraController.allowsEditing = NO;
    cameraController.delegate = delegate;
    
    [controller presentViewController:cameraController animated:YES completion:NULL];
    return YES;
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    // Process for saving an image
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    /* Image must be resized before setting it within imageView AND saving to filesystem or these two will be out of sync later,
     note that the resizing here is very crappy, but it is optimized to keep essentially what the user has just seen in the 
     camera preview as what will be on the screen and not be dealing with too much pan'ing around */
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIImage *scaledProportionalImage = [originalImage imageByScalingProportionallyToSize:CGSizeMake(screenWidth, screenHeight)];

/*Storing images in the file system derived and altered from the link below:
http://stackoverflow.com/questions/6821517/save-an-image-to-application-documents-folder-from-uiview-on-ios
        
 filepath for saving an image and also generating the MeasurementID follows the format below:
        DocumentPath/MOLEIDdelimitJAN_01,_2014_12colon01
*/
    
    //See above for details, but measurement data saved synchronously, measurement photo data saved asynch
    NSString *measurementID = [self measurementIDForSavedMeasurement];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",docsDirectory,measurementID];
    [self.moleImageView setImage:scaledProportionalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    dispatch_queue_t imageSaveQ = dispatch_queue_create("imageSaveToFileSystem", NULL);
    dispatch_async(imageSaveQ,^{
        NSData *pngData = UIImagePNGRepresentation(scaledProportionalImage);
        [pngData writeToFile:filePath atomically:YES];}); //Write the file
}

#pragma mark - Measurement data storage helper methods

/* Returns measurementID of photo, saves Measurement info into core data,
 sets the Measurement object that is created to its property within moleViewController, and
 sets the boolean value coming back.  Also sends this new mole to BridgeServer
 The name format looks like this:
 2delimitDec_29,_2014_17colon45colon56.png
 */
-(NSString *)measurementIDForSavedMeasurement
{
    NSString *moleIDString = [self.moleID stringValue];
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM_dd,_yyyy_HH:mm:ss"];
    NSString *dateString = [format stringFromDate:now];
    NSString *measurementName = [NSString stringWithFormat:@"%@delimit%@.png",moleIDString,dateString];
    //filePath = [filePath stringByAppendingString:@"delimit"];
    //filePath = [filePath stringByAppendingString:dateString];
    //filePath = [filePath stringByAppendingString:@".png"];
    measurementName = [measurementName stringByReplacingOccurrencesOfString:@":" withString:@"colon"];
    
    NSNumber *absoluteReferenceDiameter = [self.refConverter millimeterValueForReference:self.currentReference.titleLabel.text];
    
    //Create default mole measurement
    CGPoint screenCenter = [vars locationOfScreenCenterOnScrollView:self.scrollView atScale:self.scrollView.zoomScale];
    NSNumber *defaultMeasurementToolDiameter = [NSNumber numberWithFloat:20.0];
    NSNumber *defaultRefToolDiameter = [NSNumber numberWithFloat:75.0];
    NSNumber *absoluteMoleDiameter =
    [Measurement calculateAbsoluteMoleDiameterFromMeasurementDiameter:defaultMeasurementToolDiameter
                                                withReferenceDiameter:defaultRefToolDiameter
                                        withAbsoluteReferenceDiameter:absoluteReferenceDiameter];
    CGPoint measureLocation = CGPointMake(screenCenter.x + 40.0, screenCenter.y + 70.0);
    CGPoint refLocation = CGPointMake(screenCenter.x - 40.0, screenCenter.y - 70.0);
    
    //This serves to both create the measurement in core data and save it to the current measurement
    if (self.measurement)
    {
        [self saveMeasurementData];
    }
    
    self.measurement = [Measurement moleMeasurementForMole:self.mole
                                                  withDate:now
                                                 withPhoto:measurementName
                                   withMeasurementDiameter:defaultMeasurementToolDiameter
                                          withMeasurementX:[NSNumber numberWithDouble:measureLocation.x]
                                          withMeasurementY:[NSNumber numberWithDouble:measureLocation.y]
                                     withReferenceDiameter:defaultRefToolDiameter
                                            withReferenceX:[NSNumber numberWithDouble:refLocation.x]
                                            withReferenceY:[NSNumber numberWithDouble:refLocation.y]
                                         withMeasurementID:measurementName
                             withAbsoluteReferenceDiameter:absoluteReferenceDiameter
                                  withAbsoluteMoleDiameter:absoluteMoleDiameter
                                       withReferenceObject:self.currentReference.titleLabel.text
                                    inManagedObjectContext:self.context];
    
    
    
    return measurementName;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self hasValidMoleName:self.moleNameTextField.text] == NO)
    {
        return NO;
    }
    [self.view endEditing:YES];
    [self.moleNameTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textFieldText = textField.text;
    self.moleNameTextField.text = textFieldText;
    [self.moleNameTextField resignFirstResponder];
}

#pragma mark - ScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float newZoomScale = self.scrollView.zoomScale;
    if (newZoomScale != self.oldZoomScale)
    {
        self.oldZoomScale = newZoomScale;
        [self.selectedMeasuringTool drawLoop];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.referenceMeasure drawLoop];
    [self.moleMeasure drawLoop];
}

#pragma mark - Deletion of moles and action sheet delegate

- (IBAction)deleteButtonTapped
{
    Mole *moleToBeDeleted = self.measurement.whichMole;
    NSString *title = [NSString stringWithFormat:@"Settings for this measurement of %@",moleToBeDeleted.moleName];
    UIAlertController *deleteMole = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete Measurement from App" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteMole];
    }];
    
    UIAlertAction *moleWasRemoved = [UIAlertAction actionWithTitle:@"Mole Removed by Doctor" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self moleWasRemoved];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self cancelMoleDeletion];
    }];
    
    [deleteMole addAction:moleWasRemoved];
    [deleteMole addAction:delete];
    [deleteMole addAction:cancel];
    
    [self presentViewController:deleteMole animated:YES completion:nil];
}

-(void)moleWasRemoved
{
    if (self.measurement == nil) {NSLog(@"Attempting to specify a null mole as deleted");return;}
    
    NSLog(@"Mole: %@ was set to 'removed' by user",self.measurement.whichMole.moleName);
    
    //Store the mole without an associated diagnosis first, then overwrite if user completes survey
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSMutableArray *removedMoleToDiagnoses = [ad.user.removedMolesToDiagnoses mutableCopy];
    //Store a removedMole record with an empty diagnosis array for now until the user potentially enters diagnoses in survey
    NSDictionary *removedMoleRecord = @{@"moleID" : [self.measurement.whichMole.moleID stringValue],
                                        @"diagnoses" : @[@"removed"]};
    
    [ad.bridgeManager signInAndSendRemovedMoleData:removedMoleRecord];
    
    [removedMoleToDiagnoses addObject:removedMoleRecord];
    ad.user.removedMolesToDiagnoses = removedMoleToDiagnoses;
    
    //Spin up survey about the removed mole
    self.removed = [[MoleWasRemovedRKModule alloc] init];
    self.removed.removedMole = self.measurement.whichMole;
    self.removed.presentingVC = self;
    [self.removed showMoleRemoved];
}

-(void)deleteMole
{
    if (self.measurement)
    {
        [self.context deleteObject:self.measurement];
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
        //reset the measurement here for the automatic save that takes place on viewWillDisappear
        self.measurement = [Measurement getMostRecentMoleMeasurementForMole:self.mole withContext:self.context];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self closeViewController:self];
}

-(void)cancelMoleDeletion
{
    NSLog(@"Mole Deletion Cancelled");
}

#pragma mark - Handle Touch Events

- (void)selectMeasuringTool:(MeasuringTool *)measuringTool
{
    self.selectedMeasuringTool = measuringTool;
    measuringTool.measuringToolState = MeasuringToolStateSelected;
    measuringTool.panRecognizer.enabled = YES;
    [measuringTool drawLoop];
    measuringTool.measuringToolLabel.hidden = NO;
    [self buttonsShowHide];
}

- (void)deselectMeasuringTools
{
    MeasuringTool * measTool;
    for (int i = 0; i < 2; i++) {
        if (i == 0) {
            measTool = self.referenceMeasure;
        } else {
            measTool = self.moleMeasure;
        }
        measTool.measuringToolState = MeasuringToolStateNormal;
        //        measTool.panRecognizer.enabled = NO;
        measTool.measuringToolLabel.hidden = YES;
        [measTool drawLoop];
    }
    self.selectedMeasuringTool = nil;
    [self.stepperIncrement stepperButtonsHide:YES];  // Hide both of the stepper buttons
    [self.nudgeUp nudgeButtonsHide:YES];  // Hide the four nudge buttons
}

- (IBAction)moleImageSingleTapped:(UITapGestureRecognizer *)recognizer
{
    [self deselectMeasuringTools];
    [self dismissAllPopTipViews];
    //If tapping background, dismiss the keyboard, but only if a valid name exists
    if ([self hasValidMoleName:self.moleNameTextField.text])
    {
        [self.view endEditing:YES];
        [self.moleNameTextField resignFirstResponder];
    }
    self.scrollView.panGestureRecognizer.enabled = YES;
    if (!self.measurement)
    {
        [self openCamera:self];
    }
    
}

- (IBAction)moleImageDoubleTapped:(UITapGestureRecognizer *)recognizer
{
    //If tapping background, dismiss the keyboard, but only if a valid name exists
    if ([self hasValidMoleName:self.moleNameTextField.text])
    {
        [self.view endEditing:YES];
        [self.moleNameTextField resignFirstResponder];
    }
    float newZoomScale;
    if (self.scrollView.zoomScale == 1.0) {
        newZoomScale = 2.5;
    } else {
        newZoomScale = 1.0;
    }
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (IBAction)stepperTouchDown:(StepperButton *)sender
{
    [sender stepperTouchDown:sender];
}

- (IBAction)stepperTouchUpInside:(StepperButton *)sender
{
    [sender stepperTouchUpInside:sender];
}

- (IBAction)stepperTouchDragOutside:(StepperButton *)sender
{
    [sender stepperTouchDragOutside:sender];
}

- (void)updateDiameterWithChangeValue:(NSNumber *)diameterChangeValue
{
    self.selectedMeasuringTool.diameter += [diameterChangeValue integerValue];
    [self.selectedMeasuringTool drawLoop];
    [self updateMoleSizeFromOnScreenMeasurementTools];
}

- (IBAction)nudgeTouchDown:(NudgeButton *)sender
{
    [sender nudgeTouchDown:sender];
}

- (IBAction)nudgeTouchUpInside:(NudgeButton *)sender
{
    [sender nudgeTouchUpInside:sender];
}

- (IBAction)nudgeTouchDragOutside:(NudgeButton *)sender
{
    [sender nudgeTouchDragOutside:sender];
}

- (void)updateLocationWithChangeValue:(NSArray *)locationChangeValues
{
    float locationChange_x = [locationChangeValues[0] floatValue];
    float locationChange_y = [locationChangeValues[1] floatValue];
    
    self.selectedMeasuringTool.location_x += locationChange_x;
    self.selectedMeasuringTool.location_y += locationChange_y;
    self.selectedMeasuringTool.center = CGPointMake(locationChange_x, locationChange_y);
    [self.selectedMeasuringTool drawLoop];
}

- (void)buttonsShowHide
{
    BOOL hiddenState;
    if ((self.referenceMeasure.measuringToolState == MeasuringToolStateSelected) || (self.moleMeasure.measuringToolState == MeasuringToolStateSelected))  // If either of the measuring tools is selected...
    {
        hiddenState = NO;  // Set hiddenState to NO
    } else {
        hiddenState = YES;  // Set hiddenState to YES
    }
    [self.stepperIncrement stepperButtonsHide:hiddenState];  // set both stepper buttons based on hiddenState
    [self.nudgeUp nudgeButtonsHide:hiddenState];  // set the four nudge buttons based on hiddenState
}

#pragma mark - Random Helpers

//Checks to see if molename is a non-empty string and if there are any other moles with the same name
-(BOOL)hasValidMoleName:(NSString *)putativeMoleName
{
    BOOL validMoleName = YES;
    if ([putativeMoleName isEqualToString:@""])
    {
        validMoleName = NO;
        return validMoleName;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleName" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"moleName = %@", putativeMoleName];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if ([matches count] != 0 && ![putativeMoleName isEqualToString:self.moleName])
    {
        validMoleName = NO;
    }
    return validMoleName;
}

-(void)updateMoleSizeFromOnScreenMeasurementTools
{
    if (self.measurement)
    {
        NSNumber *absoluteReferenceDiameter = [self.refConverter millimeterValueForReference:self.currentReference.titleLabel.text];
        NSNumber *absoluteMoleDiameter =
        [Measurement calculateAbsoluteMoleDiameterFromMeasurementDiameter:[NSNumber numberWithFloat:self.moleMeasure.diameter]
                                                withReferenceDiameter:[NSNumber numberWithFloat:self.referenceMeasure.diameter]
                                        withAbsoluteReferenceDiameter:absoluteReferenceDiameter];
    
        //Round here to show user precision that is used for percent change calculations
        NSString *formattedSize = @"0.0";
        if ([absoluteMoleDiameter floatValue] > 0.0)
        {
            self.stepperDecrement.enabled = YES;
            float roundedDiameter = [[DashboardModel sharedInstance] correctFloat:[absoluteMoleDiameter floatValue]];
            formattedSize = [NSString stringWithFormat:@"%.1f",roundedDiameter];
        }
        else
        {
            self.stepperDecrement.enabled = NO;
        }
        formattedSize = [formattedSize stringByAppendingString:@" mm"];
        NSString *sizeText = @"Mole Size: ";
        sizeText = [sizeText stringByAppendingString:formattedSize];
        self.moleSizeField.text = sizeText;
    }
}

-(void)updateMoleSizeFromCurrentMeasurement
{
    NSString *formattedSize = @"0.0";
    if ([self.measurement.absoluteMoleDiameter floatValue] > 0.0)
    {
        float roundedDiameter = [[DashboardModel sharedInstance] correctFloat:[self.measurement.absoluteMoleDiameter floatValue]];
        formattedSize = [NSString stringWithFormat:@"%.1f",roundedDiameter];
    }
    float roundedDiameter = [[DashboardModel sharedInstance] correctFloat:[self.measurement.absoluteMoleDiameter floatValue]];
    formattedSize = [NSString stringWithFormat:@"%.1f",roundedDiameter];
    formattedSize = [formattedSize stringByAppendingString:@" mm"];
    NSString *sizeText = @"Mole Size: ";
    sizeText = [sizeText stringByAppendingString:formattedSize];
    self.moleSizeField.text = sizeText;
}

-(void)updateReferenceFieldWithReference:(NSString *)reference
{
    if (![self contains:@"Reference: " within:reference])
    {
        NSString *referenceLabelText = @"Reference: ";
        referenceLabelText = [referenceLabelText stringByAppendingString:reference];
        [self.currentReference setTitle:referenceLabelText forState:UIControlStateNormal];
    }
}

-(BOOL)contains:(NSString *)StrSearchTerm within:(NSString *)StrText
{
    return  [StrText rangeOfString:StrSearchTerm options:NSCaseInsensitiveSearch].location==NSNotFound?FALSE:TRUE;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL shouldSegueToComparison = YES;
    
    //Check to make sure that you have some data to fill comparisonViewController, or else it will crash
    if ([identifier isEqualToString:@"segueToComparison"])
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", self.mole];

        NSError *error = nil;
        NSArray *matches = [self.context executeFetchRequest:request error:&error];
        if ([matches count] == 0) {shouldSegueToComparison = NO;}
        if (shouldSegueToComparison == NO)
        {
            [self showPopTipViewComparison];
        }
    }
    
    return shouldSegueToComparison;
}

-(void)saveMeasurementData
{
    //Take the reference in the reference field and alter it to fit a defined vocabulary
    NSString *refObjectFormatted = [self.currentReference.titleLabel.text stringByReplacingOccurrencesOfString:@"Reference: " withString:@""];
    
    //Save any measurement changes upon leaving the MoleViewController
    if (self.measurement)
    {
        NSNumber *absoluteReferenceDiameter = [self.refConverter millimeterValueForReference:self.currentReference.titleLabel.text];
        NSNumber *absoluteMoleDiameter =
        [Measurement calculateAbsoluteMoleDiameterFromMeasurementDiameter:[NSNumber numberWithFloat:self.moleMeasure.diameter]
                                                    withReferenceDiameter:[NSNumber numberWithFloat:self.referenceMeasure.diameter]
                                            withAbsoluteReferenceDiameter:absoluteReferenceDiameter];
        
        //Save the Mole Measurement back into Core Data before leaving the screen
        self.measurement = [Measurement moleMeasurementForMole:self.mole
                                   withDate:nil
                                  withPhoto:nil
                    withMeasurementDiameter:[NSNumber numberWithFloat:self.moleMeasure.diameter]
                           withMeasurementX:[NSNumber numberWithFloat:self.moleMeasure.location_x]
                           withMeasurementY:[NSNumber numberWithFloat:self.moleMeasure.location_y]
                      withReferenceDiameter:[NSNumber numberWithFloat:self.referenceMeasure.diameter]
                             withReferenceX:[NSNumber numberWithFloat:self.referenceMeasure.location_x]
                             withReferenceY:[NSNumber numberWithFloat:self.referenceMeasure.location_y]
                          withMeasurementID:self.measurement.measurementID
              withAbsoluteReferenceDiameter:absoluteReferenceDiameter
                   withAbsoluteMoleDiameter:absoluteMoleDiameter
                        withReferenceObject:refObjectFormatted
                     inManagedObjectContext:self.context];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self saveMeasurementData];
    
    if ([segue.identifier isEqualToString:@"segueToComparison"])
    {
        ComparisonPageViewController *destVC = segue.destinationViewController;
        destVC.mole = self.mole;
        destVC.context = self.context;
    }
    else if ([segue.identifier isEqualToString:@"segueToReference"])
    {
        ReferenceSetterViewController *destVC = segue.destinationViewController;
        destVC.measurement = self.measurement;
        destVC.context = self.context;
    }
    else if ([segue.identifier isEqualToString:@"segueToHelp"])
    {
        HelpMovieViewController *destVC = segue.destinationViewController;
        destVC.helpMovieName = @"measurementDemo_2014_12_09";
    }
}


@end
