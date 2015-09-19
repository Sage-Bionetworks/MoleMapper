//
//  StepperButton.h
//  MoleView
//
//

#import "OBShapedButton.h"

typedef enum {
    StepperButtonTypeDecrement,
    StepperButtonTypeIncrement,
} StepperButtonType;


@interface StepperButton : OBShapedButton

- (void)loadImagesForButton:(StepperButton *)button withViewController:(UIViewController *)vc;

- (void)stepperButtonsHide:(BOOL)hiddenState;
- (void)stepperTouchUpInside:(StepperButton *)sender;
- (void)stepperTouchDragOutside:(StepperButton *)sender;
- (void)stepperTouchDown:(StepperButton *)sender;

@end
