//
//  MolePin.h
//  Pan
//

#import "OBShapedButton.h"
#import "ZoneViewController.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "SMCalloutView.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"


typedef enum {
    MolePinStateNormal,
    MolePinStateSelected,
} MolePinState;

@interface MolePin : OBShapedButton <UIGestureRecognizerDelegate, SMCalloutViewDelegate>

@property float pinLocation_x;
@property float pinLocation_y;
@property int molePin_State;

@property (strong, nonatomic) NSNumber *moleID;
@property (strong, nonatomic) NSString *moleName;
@property (strong, nonatomic) Mole *mole;
@property (strong, nonatomic) Measurement *mostRecentMeasurement;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (strong, nonatomic) SMCalloutView *calloutView;


+ (id)newPinAtCenterOfScreenOnViewController:(UIViewController *)vc
                                     andView:(UIView *)view
                               andScrollView:(UIScrollView *)sv;

- (id)initMolePinAtLocation:(CGPoint)location
           onViewController:(id)vc
                    andView:(UIView *)view
              andScrollView:(UIScrollView *)sv;

- (void)setMolePinState:(int)MolePinState;


// + (id)newPinAtCenterOfScreenOnView:(UIView *)targetView;  // DTR 2013.11.26 Depricated

// + (id)newPinAtLocationX:(NSNumber *)moleLocationX atLocationY:(NSNumber *)moleLocationY onView:(UIView *)targetView;  // DTR 2013.11.26 Depricated

@end

