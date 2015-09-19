//
//  NudgeButton.h
//  MoleView
//
//

#import "OBShapedButton.h"

typedef enum {
    NudgeButtonTypeUp,
    NudgeButtonTypeRight,
    NudgeButtonTypeDown,
    NudgeButtonTypeLeft,
} NudgeButtonType;

@interface NudgeButton : OBShapedButton

- (void)loadImagesForButton:(NudgeButton *)button withViewController:(UIViewController *)vc;

- (void)nudgeButtonsHide:(BOOL)hiddenState;
- (void)nudgeTouchUpInside:(NudgeButton *)sender;
- (void)nudgeTouchDragOutside:(NudgeButton *)sender;
- (void)nudgeTouchDown:(NudgeButton *)sender;

@end
