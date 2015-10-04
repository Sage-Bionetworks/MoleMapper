//
//  MolePin.m
//  Pan
//

#import "MolePin.h"
#import "VariableStore.h"  // molePin images live here.
#import "ZoneViewController.h"
#import "MoleNameGenerator.h"
#import "Mole+MakeAndMod.h"
#import "Mole.h"
#import "AppDelegate.h"//

@interface MolePin ()
{
    VariableStore *vars;
}

@property (strong, nonatomic) UIViewController *parentViewController;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIScrollView *parentScrollView;


@property (strong, nonatomic) UIViewController *vc;  // DTR 2013.11.26 Depricated
@property (strong, nonatomic) UIView *targetView;  // DTR 2013.11.26 Depricated
@property (strong, nonatomic) UIScrollView *scrollView;  // DTR 2013.11.26 Depricated

@end

@implementation MolePin

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)newPinAtCenterOfScreenOnViewController:(UIViewController *)vc
                                     andView:(UIView *)view
                               andScrollView:(UIScrollView *)sv
{
    MolePin *molePin = [[MolePin alloc] initPinAtCenterOfScreenOnViewController:(id)vc
                                                                        andView:(UIView *)view
                                                                  andScrollView:(UIScrollView *)sv];
    MoleNameGenerator *mng = [[MoleNameGenerator alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mng.context = appDelegate.managedObjectContext;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *moleNameGender = [standardUserDefaults objectForKey:@"moleNameGender"];
    NSString *moleName = [mng randomUniqueMoleNameWithGenderSpecification:moleNameGender];
    molePin.moleName = moleName;
    [molePin setMolePinState:MolePinStateSelected];
    return molePin;
}

- (id)initPinAtCenterOfScreenOnViewController:(id)vc
                                      andView:(UIView *)view
                                andScrollView:(UIScrollView *)sv
{
    vars = [VariableStore sharedVariableStore];
    CGPoint centerPoint = [vars locationOfScreenCenterOnScrollView:sv atScale:(float)sv.zoomScale];
    self = [self initMolePinAtLocation:centerPoint
                      onViewController:(id)vc
                               andView:(UIView *)view
                         andScrollView:(UIScrollView *)sv];
    int nextMoleID = [Mole getNextValidMoleID];
    _moleID = [NSNumber numberWithInt:nextMoleID];
    MoleNameGenerator *mng = [[MoleNameGenerator alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    mng.context = appDelegate.managedObjectContext;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *moleNameGender = [standardUserDefaults objectForKey:@"moleNameGender"];
    NSString *moleName = [mng randomUniqueMoleNameWithGenderSpecification:moleNameGender];
    _moleName = moleName;
    [self setMolePinState:MolePinStateSelected];
    return self;
}


- (id)initMolePinAtLocation:(CGPoint)location
           onViewController:(id)vc
                    andView:(UIView *)view
              andScrollView:(UIScrollView *)sv
{
    vars = [VariableStore sharedVariableStore];
    _parentViewController = vc;
    _parentView = view;
    _parentScrollView = sv;
    float width = vars.molePinUnscaledSize.width;
    float height = vars.molePinUnscaledSize.height;
    float zoomScale = self.parentScrollView.zoomScale;
    CGRect frame = CGRectMake(0.0, 0.0, width / zoomScale, height / zoomScale);
    if (self = [super initWithFrame:frame])
    {
        [self setMolePinState:MolePinStateNormal];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_panRecognizer setMinimumNumberOfTouches:1];
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelegate:self];
        [self addGestureRecognizer:_panRecognizer];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [longPressRecognizer setMinimumPressDuration:0.25];
        [longPressRecognizer setAllowableMovement:10];
        [longPressRecognizer setDelegate:self];
        [self addGestureRecognizer:longPressRecognizer];
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTapRecognizer setNumberOfTapsRequired:1];
        [singleTapRecognizer requireGestureRecognizerToFail: longPressRecognizer];
        [singleTapRecognizer setDelegate:self];
        [self addGestureRecognizer:singleTapRecognizer];
        
        [self.parentView addSubview:self];
        
        self.pinLocation_x = location.x;
        self.pinLocation_y = location.y;
        self.center = location;
    }  // End if (self = [super initWithFrame:frame])
    return self;
}


#pragma mark User Events

// NEEDED for selectThenPan behavior.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ((gestureRecognizer == self.longPressRecognizer) && (otherGestureRecognizer == self.panRecognizer))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (IBAction)handleTouchDown:(MolePin *)molePin
{
    self.parentScrollView.panGestureRecognizer.enabled = NO;
}

- (IBAction)handleTouchUpInside:(MolePin *)molePin
{
    [self setMolePinState:MolePinStateNormal];
    self.parentScrollView.panGestureRecognizer.enabled = YES;
    self.longPressRecognizer.enabled = YES;
    [vars.zoneViewController dismissAllPopTipViews];
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    [self setMolePinState:MolePinStateSelected];
    self.panRecognizer.enabled = YES;
    self.longPressRecognizer.enabled = NO;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    self.pinLocation_x = self.center.x;
    self.pinLocation_y = self.center.y;
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
        [self handleTouchUpInside:self];
    }
}

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    
    UIButton *deleteMoleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteMoleButton.frame = CGRectMake(0,0,30,30);
    //UIImage *deleteButtonImage = [UIImage imageNamed:@"trash.png"];
    UIImage *deleteButtonImage = [UIImage imageNamed:@"barButtonSettings"];
    
    [deleteMoleButton setBackgroundImage:deleteButtonImage forState:UIControlStateNormal];
    [deleteMoleButton addTarget:self action:@selector(deleteMolePinOnZoneViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailButton.frame = CGRectMake(0,0,30,30);
    UIImage *detailButtonImage = [UIImage imageNamed:@"measurementIcon"];
    [detailButton setBackgroundImage:detailButtonImage forState:UIControlStateNormal];
    [detailButton addTarget:self action:@selector(calloutDisclosureTapped) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.calloutView)
    {
        self.calloutView = [SMCalloutView platformCalloutView]; //used to just be new here
        self.calloutView.delegate = self;
        self.calloutView.title = self.moleName;
        
        self.calloutView.leftAccessoryView = deleteMoleButton;
        self.calloutView.rightAccessoryView = detailButton;
        
        NSString *subtitle = @"Mole Size: ";
        if (self.mostRecentMeasurement.absoluteMoleDiameter)
        {
            
            NSString* formattedSize = [NSString stringWithFormat:@"%.1f", ceilf([self.mostRecentMeasurement.absoluteMoleDiameter floatValue] * 10.0f) / 10.0f];
            subtitle = [subtitle stringByAppendingString:formattedSize];
            subtitle = [subtitle stringByAppendingString:@" mm"];
        }
        else
        {
            subtitle = [subtitle stringByAppendingString:@"N/A"];
        }
        self.calloutView.subtitle = subtitle;
        
        //Enables the callout to appear right next to the pin instead of its transparent outline where the yellow highlight will go
        self.calloutView.calloutOffset = CGPointMake(0, 20);
        //self.calloutView.contentView = nil;
        self.calloutView.permittedArrowDirection = SMCalloutArrowDirectionAny;
        //self.calloutView.constrainedInsets = UIEdgeInsetsMake(self.parentViewController.topLayoutGuide.length, 0, self.parentViewController.bottomLayoutGuide.length, 0);
    
        [self.calloutView presentCalloutFromRect:self.frame
                                      inView:self.parentView
                           constrainedToView:self.parentView
                                    animated:YES];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"showDemoInfo"] == YES)
    {
        [vars.zoneViewController showPopTipViewGoToMeasure:self.calloutView.rightAccessoryView];
        //[ud setObject:[NSNumber numberWithBool:NO] forKey:@"firstViewCallout"];
    }

}

-(void)deleteMolePinOnZoneViewController
{
    ZoneViewController *zvc = vars.zoneViewController;
    zvc.moleToBeDeleted = self;
    [zvc deleteMolePinButtonTapped:self];
}

- (void)calloutDisclosureTapped
{
    ZoneViewController *zvc = vars.zoneViewController;
    [zvc performSegueWithIdentifier:@"GoToMoleView" sender:self];
}

- (void)setMolePinState:(int)newState
{
    if (newState == MolePinStateNormal) {
        [self setImage:vars.molePinNormal forState:UIControlStateNormal];
        [self setImage:vars.molePinHighlighted forState:UIControlStateHighlighted];
        //Change this back to NO if you want to have only the select, then move behavior
        self.panRecognizer.enabled = YES;
        self.longPressRecognizer.enabled = YES;
    } else {
        [self setImage:vars.molePinSelected forState:UIControlStateNormal];
        [self setImage:vars.molePinSelected forState:UIControlStateHighlighted];
        [self panRecognizer].enabled = YES;
        self.longPressRecognizer.enabled = NO;
    }
    self.molePin_State = newState;
    [vars.zoneViewController updateMolePinBarButtonStates];
}

@end
