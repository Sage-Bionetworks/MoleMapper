//
//  ZoneViewController.m
//  
//


#import "ZoneViewController.h"
#import "VariableStore.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import "AppDelegate.h"
#import "MoleNameGenerator.h"
#import "MoleViewController.h"
#import "ScaledImageView.h"
#import "VariableStore.h"
#import "MolePin.h"
#import "UIImage+Extras.h"
#import "UIImage+Resize.h"
#import "BodyMapViewController.h"
#import "Measurement+MakeAndMod.h"
#import "HelpMovieViewController.h"
#import "CMPopTipView.h"
#import "KLCPopup.h"
#import "MoleWasRemovedRKModule.h"

@interface ZoneViewController () <UIScrollViewDelegate,CMPopTipViewDelegate>
{
    VariableStore *vars;
}

@property float oldZoomScale;
@property (nonatomic,strong) NSMutableArray *molePinsOnImage;
@property (nonatomic,strong) MoleNameGenerator *nameGenerator;
@property (strong, nonatomic) UIImageView *zoneImageView;
@property (strong, nonatomic) UIImage *zoneImage;
@property BOOL showMolePinDropAnimation;

@property (strong, nonatomic) CMPopTipView *popTipViewPointToPinButton;
@property (strong, nonatomic) CMPopTipView *popTipViewExport;
@property (strong, nonatomic) CMPopTipView *popTipViewPinTap;

@property (strong, nonatomic) MoleWasRemovedRKModule *removed;

@end

@implementation ZoneViewController

#pragma mark - Setters and Getters

-(NSMutableArray *)molePinsOnImage
{
    if (!_molePinsOnImage) _molePinsOnImage = [[NSMutableArray alloc] init];
    return _molePinsOnImage;
}

-(MoleNameGenerator *)nameGenerator
{
    if (!_nameGenerator)
    {
        _nameGenerator = [[MoleNameGenerator alloc] init];
        _nameGenerator.context = self.context;
    }
    return _nameGenerator;
}

-(UIImage *)zoneImage
{
    if (!_zoneImage)
    {
        //Check to see if there is a valid image loaded up from Core Data
        _zoneImage = [Zone imageForZoneName:self.zoneID];
        if (self.hasValidImageData == NO)
        {
            _zoneImage = nil;
            //[self openCamera:self]; Not compatible with other elements popping up
            //if nothing from core data, then load up the default
            UIImage *rawImage = [UIImage imageNamed:@"zoneNoPhoto.png"];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            _zoneImage = [rawImage imageByScalingProportionallyToSize:CGSizeMake(screenWidth, screenHeight)];
            
        }
    }
    return _zoneImage;
}

-(UIImageView *)zoneImageView
{
    if (!_zoneImageView)
    {
        _zoneImageView = [[UIImageView alloc] initWithImage:self.zoneImage];
        //_zoneImageView.contentMode = UIViewContentModeCenter;
        _zoneImageView.userInteractionEnabled = YES;
        _zoneImageView.frame = CGRectMake(0,0,self.zoneImage.size.width,self.zoneImage.size.height);
    }
    
    return _zoneImageView;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasValidImageData = [Zone hasValidImageDataForZoneID:self.zoneID];
    self.automaticallyAdjustsScrollViewInsets = YES;
    vars = [VariableStore sharedVariableStore];
    vars.zoneViewController = self;
    self.navigationItem.title = self.zoneTitle;
    self.showMolePinDropAnimation = YES;
    self.oldZoomScale = self.scrollView.zoomScale;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoneImageDoubleTapped:)];
	[doubleTapRecognizer setNumberOfTapsRequired:2];
	[doubleTapRecognizer setDelegate:self];
	[self.zoneImageView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoneImageSingleTapped:)];
	[singleTapRecognizer setNumberOfTapsRequired:1];
    [singleTapRecognizer requireGestureRecognizerToFail: doubleTapRecognizer];
	[singleTapRecognizer setDelegate:self];
	[self.zoneImageView addGestureRecognizer:singleTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[vars configureScaledImageView:self.zoneImageView andScrollView:self.scrollView withImage:self.zoneImage]
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.zoneImageView.frame.size;
    [self.scrollView addSubview:self.zoneImageView];
    self.scrollView.contentOffset = CGPointMake(0, 5);
    
    self.scrollView.minimumZoomScale = 0.8;
    self.scrollView.maximumZoomScale = 10.0;
    self.scrollView.delegate=self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.zoomScale = 1.0;
    //self.zoneImageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    
    [self setupAllMolesFromCoreData];
    
    //animation code from here: http://stackoverflow.com/questions/1671966/animation-how-to-make-uibutton-move-from-right-to-left-when-view-is-loaded
    //if (self.showMolePinDropAnimation)
    //{
    for (MolePin *molePin in self.molePinsOnImage)
    {
        CGPoint newCenter = CGPointMake(molePin.center.x, molePin.pinLocation_y);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        molePin.center = newCenter;
        [UIView commitAnimations];
    }
    //}
    [self updateMolePinBarButtonStates];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //Checking for valid Image data to prevent coming up after taking photo
    if ([ud valueForKey:@"showDemoInfo"] == [NSNumber numberWithBool:YES] && self.hasValidImageData == NO)
    {
        [self showPhotoPopup:self];
    }

    /*
    //If this isn't part of a demo and it's an undocumented zone, automatically open the camera
    if (self.hasValidImageData == NO &&
        [ud valueForKey:@"showDemoInfo"] == [NSNumber numberWithBool:NO])
    {
        [self openCamera:self];
    }
     */
    
    //If you are using demo mode or this is the first time you're seeing a valid photo
    if (([ud objectForKey:@"firstViewPinButton"] == [NSNumber numberWithBool:YES] && self.hasValidImageData) ||
        ([ud valueForKey:@"showDemoInfo"] == [NSNumber numberWithBool:YES] && self.hasValidImageData))
    {
        [self showPopTipViewPointToPinButton];
        [ud setObject:[NSNumber numberWithBool:NO] forKey:@"firstViewPinButton"];
    }
    
    
    NSNumber *exportReminderCounter = [ud objectForKey:@"exportReminderCounter"];
    long tempCounter = [exportReminderCounter integerValue];
    if (tempCounter % 10 == 1 && self.hasValidImageData)
    {
        [self showPopTipViewExportButton];
    }
    tempCounter++;
    [ud setObject:[NSNumber numberWithLong:tempCounter] forKey:@"exportReminderCounter"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Set this flag to NO so that the animation doesn't occur upon returning from MeasurementView 'backwards' naviagtion
    //Will get set back to yes only on viewDidLoad coming from bodyMapViewController
    self.showMolePinDropAnimation = NO;
    [self saveAllMolesOnScreen];
    [self dismissAllCallouts];
    [self dismissAllPopTipViews];
    //Need to get rid of the scrollview delegate here because assign is used for
    //delegate assignment
    }

-(void)viewDidDisappear:(BOOL)animated
{
    [self.molePinsOnImage removeAllObjects];
    for (UIView *view in self.zoneImageView.subviews)
    {
        if (view)
        {
            [view removeFromSuperview];
        }
    }
    self.scrollView.delegate = nil;

}

#pragma mark - CMPopTipView methods

- (void)showPopTipViewPointToPinButton
{
    NSString *message = @"Tap to drop\na mole pin";
    self.popTipViewPointToPinButton = [[CMPopTipView alloc] initWithMessage:message];
    self.popTipViewPointToPinButton.delegate = self;
    [self.popTipViewPointToPinButton presentPointingAtBarButtonItem:self.addMolePin animated:YES];
}

- (void)showPopTipViewExportButton
{
    NSString *message = @"Export zone photo\nand mole data\nfor your records";
    self.popTipViewExport= [[CMPopTipView alloc] initWithMessage:message];
    self.popTipViewExport.delegate = self;
    [self.popTipViewExport presentPointingAtBarButtonItem:self.exportButton animated:YES];
}

-(void)showPopTipViewMovePin
{
    NSString *message = @"Move the pin crosshairs\nover a mole";
    if ([self.molePinsOnImage objectAtIndex:0] != nil)
    {
        self.popTipViewPinTap = [[CMPopTipView alloc] initWithMessage:message];
        self.popTipViewPinTap.delegate = self;
        [self.popTipViewPinTap presentPointingAtBarButtonItem:self.addMolePin animated:YES];
    }
}

-(void)showPopTipViewGoToMeasure:(UIView *)viewToPointAt
{
    NSString *message = @"Tap for mole\ndetails";
    self.popTipViewGoToMeasure = [[CMPopTipView alloc] initWithMessage:message];
    [self.popTipViewGoToMeasure presentPointingAtView:viewToPointAt inView:self.zoneImageView animated:YES];
}

//Only Delegate method for CMPopTipView
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    popTipView = nil;
}

-(void)dismissAllPopTipViews
{
    [self.popTipViewExport dismissAnimated:YES];
    [self.popTipViewPointToPinButton dismissAnimated:YES];
    [self.popTipViewPinTap dismissAnimated:YES];
    [self.popTipViewGoToMeasure dismissAnimated:YES];
}

#pragma mark - KLCPopup Welcome

- (void)showPhotoPopup:(id)sender
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
    welcomeLabel.text = @"Take a photo of the zone\nthen drop in a mole pin";
    
    UIImageView *demoShot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zoneDemoPin"]];
    
    UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    nextButton.contentEdgeInsets = UIEdgeInsetsMake(12, 50, 12, 50);
    nextButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 6.0;
    [nextButton addTarget:self action:@selector(nextButtonPressedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* demoOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    demoOffButton.translatesAutoresizingMaskIntoConstraints = NO;
    demoOffButton.contentEdgeInsets = UIEdgeInsetsMake(14, 24, 14, 24);
    demoOffButton.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:0.9];
    [demoOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [demoOffButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    demoOffButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [demoOffButton setTitle:@"Turn Off Demo" forState:UIControlStateNormal];
    demoOffButton.titleLabel.numberOfLines = 1;
    demoOffButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    demoOffButton.layer.cornerRadius = 6.0;
    [demoOffButton addTarget:self action:@selector(demoOffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:welcomeLabel];
    [contentView addSubview:demoShot];
    [contentView addSubview:demoOffButton];
    [contentView addSubview:nextButton];
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, nextButton, demoShot, demoOffButton, welcomeLabel);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[demoShot]-(16)-[welcomeLabel]-(16)-[nextButton]-(10)-[demoOffButton]-(16)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[welcomeLabel]-(10)-|"
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

- (void)showDragPopup:(id)sender
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
    welcomeLabel.text = @"Use the hand icon to drag\nthe pin over your mole";
    
    UIImageView *demoShot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zoneDemoDrag"]];
    
    UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    nextButton.contentEdgeInsets = UIEdgeInsetsMake(12, 50, 12, 50);
    nextButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 6.0;
    [nextButton addTarget:self action:@selector(nextButtonPressedDrag:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* demoOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    demoOffButton.translatesAutoresizingMaskIntoConstraints = NO;
    demoOffButton.contentEdgeInsets = UIEdgeInsetsMake(14, 24, 14, 24);
    demoOffButton.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:0.9];
    [demoOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [demoOffButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    demoOffButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [demoOffButton setTitle:@"Turn Off Demo" forState:UIControlStateNormal];
    demoOffButton.titleLabel.numberOfLines = 1;
    demoOffButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    demoOffButton.layer.cornerRadius = 6.0;
    [demoOffButton addTarget:self action:@selector(demoOffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:welcomeLabel];
    [contentView addSubview:demoShot];
    [contentView addSubview:demoOffButton];
    [contentView addSubview:nextButton];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, nextButton, demoShot, demoOffButton, welcomeLabel);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[demoShot]-(16)-[welcomeLabel]-(16)-[nextButton]-(10)-[demoOffButton]-(16)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];

    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[welcomeLabel]-(10)-|"
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

- (void)showMeasurePopup:(id)sender
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
    welcomeLabel.text = @"To measure a mole, tap\nthe pin and then the measurement icon";
    
    UIImageView *demoShot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zoneDemoMeasure"]];
    
    UIButton* nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    nextButton.contentEdgeInsets = UIEdgeInsetsMake(12, 50, 12, 50);
    nextButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 6.0;
    [nextButton addTarget:self action:@selector(nextButtonPressedMeasure:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* demoOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    demoOffButton.translatesAutoresizingMaskIntoConstraints = NO;
    demoOffButton.contentEdgeInsets = UIEdgeInsetsMake(14, 24, 14, 24);
    demoOffButton.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:0.9];
    [demoOffButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [demoOffButton setTitleColor:[[nextButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    demoOffButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [demoOffButton setTitle:@"Turn Off Demo" forState:UIControlStateNormal];
    demoOffButton.titleLabel.numberOfLines = 1;
    demoOffButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    demoOffButton.layer.cornerRadius = 6.0;
    [demoOffButton addTarget:self action:@selector(demoOffButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:welcomeLabel];
    [contentView addSubview:demoShot];
    [contentView addSubview:demoOffButton];
    [contentView addSubview:nextButton];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, nextButton, demoShot, demoOffButton, welcomeLabel);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[demoShot]-(16)-[welcomeLabel]-(16)-[nextButton]-(10)-[demoOffButton]-(16)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[welcomeLabel]-(10)-|"
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

- (void)nextButtonPressedPhoto:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    //Call the next popup in the tutorial series
    [self performSelector:@selector(showDragPopup:) withObject:self afterDelay:0.4];
}

- (void)nextButtonPressedDrag:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    [self performSelector:@selector(showMeasurePopup:) withObject:self afterDelay:0.4];
}

- (void)nextButtonPressedMeasure:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    //Last demo slide will open the camera assuming no photo exists
    if (self.hasValidImageData == NO)
    {
        [self openCamera:self];
    }
}

- (void)demoOffButtonPressed:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        [(UIView*)sender dismissPresentingPopup];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[NSNumber numberWithBool:NO] forKey:@"showDemoInfo"];
}

- (void)fieldCancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Scrollview Delegate Methods

- (UIView *)viewForZoomingInScrollView:scrollView
{
    // return self.containerView;
    return self.zoneImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float newZoomScale = self.scrollView.zoomScale;
    if (newZoomScale != self.oldZoomScale)
    {
        [self handleZoneViewZoomScale:newZoomScale];
        self.oldZoomScale = newZoomScale;
    }
    
}

#pragma mark - MFMailComposeViewController Delegate Methods
//Notes for this implementation found here: http://www.appcoda.com/ios-programming-101-send-email-iphone-app/

- (IBAction)showEmail:(id)sender
{
    [self dismissAllPopTipViews];
    [self saveAllMolesOnScreen];
    Zone *zone = [Zone zoneForZoneID:self.zoneID withZonePhotoFileName:nil inManagedObjectContext:self.context];
    
    
    NSString *emailTitle = [self emailTitleForZone:zone];
    NSString *messageBody = [self emailBodyForZone:zone];
    NSArray *toRecipents = [NSArray arrayWithObject:[self recipientForEmail]];
    NSString *filePath = [Zone imageFullFilepathForZoneID:self.zoneID];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
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

-(NSString *)emailTitleForZone:(Zone *)zone
{
    NSString *title = [NSString stringWithFormat:@"[Mole Mapper] %@",self.zoneTitle];
    return title;
}

-(NSString *)emailBodyForZone:(Zone *)zone
{
    NSString *zoneData = [NSString stringWithFormat:@"Body Map Zone Name: %@\n",self.zoneTitle];
    NSSet *molesInZone = zone.moles;
    NSString *moleNameList = [NSString stringWithFormat:@"Moles in %@ Zone:\n",self.zoneTitle];
    for (Mole *mole in molesInZone)
    {
        moleNameList = [moleNameList stringByAppendingString:[NSString stringWithFormat:@"- %@\n",mole.moleName]];
    }
    NSString *attachmentNotice = [NSString stringWithFormat:@"\n[Photo of %@ Zone Attached]\n",self.zoneTitle];
    //NSString *postScript = @"To auto-populate these emails with your email address, please go to Settings in the Menu screen.\n";
    NSString *body = [NSString stringWithFormat:@"%@%@%@",zoneData,moleNameList,attachmentNotice];//postScript];
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

- (IBAction)openCamera:(id)sender
{
    [self launchCameraControllerFromViewController:self usingDelegate:self];
}

//Note this is coming from http://www.instructables.com/id/How-to-use-the-camera-in-your-iOS-program/step3/launchCameraController/
-(BOOL)launchCameraControllerFromViewController: (UIViewController *) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    BOOL truefalse = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]; //variable to check whether there is a camera available
    //if there is a camera, the delegate passed exists, and the controller passed exists, proceed on, otherwise don't go any further
    if (!truefalse || (delegate == nil) || (controller == nil)) {
        NSLog(@"no can do, delegate/camera/view controller doesn't exist! (Or you could be on the simulator, which won't work)");
        return NO;
    }
    
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
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
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage]; //Assign the original image to originalImage
    }
    
    UIImage *resizedImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:self.view.bounds.size interpolationQuality:kCGInterpolationHigh];
    
    [self.zoneImageView setImage:resizedImage];
    self.zoneImageView.userInteractionEnabled = YES;
    self.zoneImageView.frame = CGRectMake(0,0,resizedImage.size.width,resizedImage.size.height);
    
    self.hasValidImageData = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    //Update the ZoneViewController to signify that an image has been picked for a given zone
    BodyMapViewController *bmvc = self.navigationController.viewControllers[0];
    UIImageView *viewToUpdate = [bmvc imageViewForZoneID:self.zoneID];
    [vars updateToHasImageForZoneID:self.zoneID toView:viewToUpdate];
    
    //Storing images in the file system derived and altered from the link below:
    //http://stackoverflow.com/questions/6821517/save-an-image-to-application-documents-folder-from-uiview-on-ios
    
    dispatch_queue_t imageSaveQ = dispatch_queue_create("imageSaveToFileSystem", NULL);
    dispatch_async(imageSaveQ, ^{
        NSData *pngData = UIImagePNGRepresentation(resizedImage);
        NSString *fileName = [Zone imageFilenameForZoneID:self.zoneID];
        NSString *filePath = [Zone imageFullFilepathForZoneID:self.zoneID];
        
        //Write the changes into Core Data
        [Zone zoneForZoneID:self.zoneID withZonePhotoFileName:fileName inManagedObjectContext:self.context];
        
        [pngData writeToFile:filePath atomically:YES]; //Write the file
        
    });
    
}

#pragma mark - Handle Touch Events

- (IBAction)addMolePinButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissAllCallouts];
    MolePin *molePin = [MolePin newPinAtCenterOfScreenOnViewController:self
                                                               andView:self.zoneImageView
                                                         andScrollView:self.scrollView];
    molePin.molePin_State = 1;
    [self addToMolePinsOnImageArray:molePin];
    Zone *zone = [Zone zoneForZoneID:self.zoneID withZonePhotoFileName:nil inManagedObjectContext:self.context];
    molePin.mole = [Mole moleWithMoleID:molePin.moleID
            withMoleName:molePin.moleName
                 atMoleX:nil
                 atMoleY:nil
                  inZone:zone
  inManagedObjectContext:self.context];

    [self updateMolePinBarButtonStates];
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"firstViewMovePin"] == [NSNumber numberWithBool:YES])
    {
        [self showPopTipViewMovePin];
        [ud setObject:[NSNumber numberWithBool:NO] forKey:@"firstViewMovePin"];
    }
    
}

- (IBAction)deleteMolePinButtonTapped:(MolePin *)sender
{
    self.moleToBeDeleted = sender;
    NSString *title = [NSString stringWithFormat:@"Delete mole named %@?",sender.moleName];
    UIAlertController *deleteMole = [UIAlertController alertControllerWithTitle:title message:@"If this mole was removed by a doctor, please tap the 'Mole Removed by Doctor' button" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete Mole from App" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
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

-(void)deleteMole
{
    MolePin *molePinToDelete = self.moleToBeDeleted;
    
    if (molePinToDelete)
    {
        [molePinToDelete.calloutView dismissCalloutAnimated:NO];
        [molePinToDelete removeFromSuperview];                  // remove from superview
        [self.molePinsOnImage removeObject:molePinToDelete];    // remove from array
        if (molePinToDelete.mole)
        {
            [self.context deleteObject:molePinToDelete.mole]; // remove from persistant store
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate saveContext];
        }
        
    }
    [self updateMolePinBarButtonStates];
    [self dismissAllCallouts];
    self.moleToBeDeleted = nil;
}

-(void)moleWasRemoved
{
    NSLog(@"Mole: %@ was set to 'removed' by user",self.moleToBeDeleted.moleName);
    self.removed = [[MoleWasRemovedRKModule alloc] init];
    self.removed.removedMole = self.moleToBeDeleted.mole;
    self.removed.presentingVC = self;
    [self.removed showMoleRemoved];
}

-(void)cancelMoleDeletion
{
    self.moleToBeDeleted = nil;
}

- (void)updateMolePinBarButtonStates
{
    int isSelected = NO;
    if ([self.molePinsOnImage count] > 0)
    {
        for (MolePin *molePin in self.molePinsOnImage)
        {
            isSelected = (molePin.molePin_State == MolePinStateSelected);
            if (isSelected) {
                break;
            }
        };  // end for (MolePin *molePin in self.molePinsOnImage)
    }  // end if
    self.deleteMolePin.enabled = isSelected;
    self.addMolePin.enabled = !isSelected;
}

- (IBAction)zoneImageSingleTapped:(UITapGestureRecognizer *)recognizer
{
    [self handleSingleTapOnZoneImageBackground];
    [self dismissAllCallouts];
    [self dismissAllPopTipViews];
}

- (void)handleSingleTapOnZoneImageBackground
{
    for (MolePin *molePin in self.molePinsOnImage)
    {
        [molePin setMolePinState:MolePinStateNormal];
        molePin.pinLocation_x = molePin.center.x;
        molePin.pinLocation_y = molePin.center.y;
        //[molePin.calloutView dismissCalloutAnimated:YES];
    };
    [self dismissAllCallouts];
    // end for (MolePin *molePin in self.molePinsOnImage)
    self.scrollView.panGestureRecognizer.enabled = YES;
    [self updateMolePinBarButtonStates];
    if (self.hasValidImageData == NO)
    {
        [self openCamera:self];
    }
}

- (IBAction)zoneImageDoubleTapped:(UITapGestureRecognizer *)recognizer
{
    [self handleDoubleTapOnZoneImageBackground];
    [self dismissAllCallouts];
    [self dismissAllPopTipViews];
}

- (void)handleDoubleTapOnZoneImageBackground
{
    float newZoomScale;
    if (self.scrollView.zoomScale == 1.0) {
        newZoomScale = 2.5;
    } else {
        newZoomScale = 1.0;
    }
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)addToMolePinsOnImageArray:(MolePin *)molePin
{
    [self.molePinsOnImage addObject:molePin];
    [self dismissAllPopTipViews];
}

- (void)handleZoneViewZoomScale:(float)newZoomScale;
{
    for (MolePin *molePin in self.molePinsOnImage)
    {
        float scaledWidth = vars.molePinUnscaledSize.width / newZoomScale;
        float scaledHeight = vars.molePinUnscaledSize.height / newZoomScale;
        CGRect newRect = CGRectMake(molePin.pinLocation_x, molePin.pinLocation_y, scaledWidth, scaledHeight);
        molePin.frame = newRect;
        molePin.center = newRect.origin;
    }; 
}

#pragma mark - Random Helpers

- (void)setupAllMolesFromCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mole" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    //NOTE: When making a predicate on a relationship, need to dig down to string value within object
    //Example here is that if you don't go to zoneID, you just get a pointer to match on
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"whichZone.zoneID = %@", self.zoneID];
    
    NSError *error = nil;
    NSArray *allMoles = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (Mole *mole in allMoles)
    {
        CGPoint location = CGPointMake([mole.moleX floatValue], [mole.moleY floatValue]);
        MolePin *molePin = [[MolePin alloc] initMolePinAtLocation:location
                                                 onViewController:self
                                                          andView:self.zoneImageView
                                                    andScrollView:self.scrollView];
        molePin.mole = mole;
        molePin.mostRecentMeasurement = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
        molePin.moleID = mole.moleID;
        molePin.moleName = mole.moleName;
            
        //Set up the MolePin artificially at the top of the screen (will drop down to actual place in viewWillAppear)
        CGRect frameAtTheTop = CGRectMake(molePin.frame.origin.x, 0, molePin.frame.size.width, molePin.frame.size.height);
        molePin.frame = frameAtTheTop;
        [self.molePinsOnImage addObject:molePin];
        [self.zoneImageView addSubview:molePin];
    }
}

-(void)dismissAllCallouts
{
    for (MolePin *molePin in self.molePinsOnImage)
    {
        [molePin.calloutView dismissCalloutAnimated:YES];
        molePin.calloutView = nil;
    }
}

-(void)saveAllMolesOnScreen
{
    //Go through all moles in the array and save their locations.
    Zone *zone = [Zone zoneForZoneID:self.zoneID withZonePhotoFileName:nil inManagedObjectContext:self.context];
    
    for (MolePin *molePin in self.molePinsOnImage)
    {
        [Mole moleWithMoleID:molePin.moleID
                withMoleName:molePin.moleName
                     atMoleX:[NSNumber numberWithFloat:molePin.pinLocation_x]
                     atMoleY:[NSNumber numberWithFloat:molePin.pinLocation_y]
                      inZone:zone
      inManagedObjectContext:self.context];
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MolePin *)sender
{
    [self saveAllMolesOnScreen];
    if ([segue.identifier isEqualToString:@"GoToMoleView"])
    {
        MoleViewController *destVC = segue.destinationViewController;
        
        //Call with nils like this because the mole doesn't need to be modified, just returned
        Mole *moleForSegue = [Mole moleWithMoleID:sender.moleID
                                     withMoleName:nil
                                          atMoleX:nil
                                          atMoleY:nil
                                           inZone:nil
                           inManagedObjectContext:self.context];
        
        destVC.mole = moleForSegue;
        destVC.moleID = sender.moleID;
        destVC.moleName = sender.moleName;
        destVC.context = self.context;
        destVC.zoneID = self.zoneID;
        destVC.zoneTitle = self.zoneTitle;
        Measurement *moleMeasurement = [Measurement getMostRecentMoleMeasurementForMole:moleForSegue withContext:self.context];
        destVC.measurement = moleMeasurement;
    }
    
    else if ([segue.identifier isEqualToString:@"zoneViewHelpSegue"])
    {
        HelpMovieViewController *destVC = segue.destinationViewController;
        destVC.helpMovieName = @"zoneHelpMovie";
    }
    
}

@end