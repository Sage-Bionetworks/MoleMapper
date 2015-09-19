//
//  VariableStore.h
//  ZoomBodyImage
//
//

#import <Foundation/Foundation.h>
#import "ZoneViewController.h"
#import "StepperButton.h"
#import "NudgeButton.h"

@interface VariableStore : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;
@property float drawingScale;
@property CGRect contentRect;
@property CGRect imageRect;
@property (weak, nonatomic) UIView *containerView;
@property (weak, nonatomic) UIViewController *myViewController;

@property NSDictionary *baseZones;
@property NSMutableDictionary *tagZones;


// ------------------------- DTR 2013.09.09 Vars used by 'MolePin' class BEGIN
@property (strong, nonatomic) UIImage *molePinNormal;
@property (strong, nonatomic) UIImage *molePinHighlighted;
@property (strong, nonatomic) UIImage *molePinSelected;
@property CGSize molePinUnscaledSize;

@property (strong, nonatomic) ZoneViewController * zoneViewController;  //
// ------------------------- DTR 2013.09.09 Vars used by 'MolePin' class END

@property (strong, nonatomic) StepperButton *moleViewStepperIncrement;
@property (strong, nonatomic) StepperButton *moleViewStepperDecrement;

@property (strong, nonatomic) NudgeButton *moleViewNudgeUp;
@property (strong, nonatomic) NudgeButton *moleViewNudgeRight;
@property (strong, nonatomic) NudgeButton *moleViewNudgeDown;
@property (strong, nonatomic) NudgeButton *moleViewNudgeLeft;


+ (VariableStore *)sharedVariableStore;

- (NSDictionary *)BuildTagZoneDictionaryAndButtonsWithStructureData:(NSArray *)structureData forView:(UIImageView *)view;

- (void)updateZoneButtonImages;

- (CGPoint)locationOfScreenCenterOnView:(UIView *)view atScale:(float)scale;

- (CGPoint)locationOfScreenCenterOnScrollView:(UIScrollView *)view atScale:(float)scale;

- (UIImage *)processAndScaleUIImage:(UIImage *)image;

- (void)configureScaledImageView:(UIImageView *)imageView andScrollView:(UIScrollView *)scrollView withImage:(UIImage *)image;

- (void)updateToHasImageForZoneID:(NSString *)zoneID toView:(UIImageView *)view;

- (void)animateTransparencyOfZonesWithPhotoDataOverDuration:(float)crossFadeDuration;

- (void)clearTransparencyOfAllZones;

@end
