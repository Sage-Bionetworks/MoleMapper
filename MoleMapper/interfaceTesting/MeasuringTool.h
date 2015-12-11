//
//  MeasuringTool.h
//  MoleView
//
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"

typedef enum {
    MeasuringToolTypeMoleMeasure,
    MeasuringToolTypeReferenceMeasure,
} MeasuringToolType;

typedef enum {
    MeasuringToolStateNormal,
    MeasuringToolStateSelected,
} MeasuringToolState;

typedef enum {
    MeasuringToolDiameterDefault,
} MeasuringToolDiameter;


@interface MeasuringTool : OBShapedButton <UIGestureRecognizerDelegate>  //                          XXXXXXXXXX

@property float diameter;
@property float location_x;
@property float location_y;

@property (strong, nonatomic) UIViewController *parentViewController;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIScrollView *parentScrollView;  //                          XXXXXXXXXX
@property int measuringToolState;
@property int measuringToolType;
@property (strong, nonatomic) UILabel *measuringToolLabel;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;

- (id)initWithType:(int)measuringToolType
       andDiameter:(float)diameter
        atLocation:(CGPoint)location
  onViewController:(id)vc
           andView:(UIView *)view
     andScrollView:(UIScrollView *)sv;

- (void)drawLoop;

//Check to see that measurement tool is non-nil and has non-zero location and diameter
- (BOOL)hasValidMeasurementInfo;

@end
