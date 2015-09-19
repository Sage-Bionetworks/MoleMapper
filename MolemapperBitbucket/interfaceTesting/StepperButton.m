//
//  StepperButton.m
//  MoleView
//
//

#import "StepperButton.h"
#import "VariableStore.h"


@interface StepperButton ()
{
    VariableStore *vars;
}
@property (strong,nonatomic)UIViewController *parentViewController;
@property (weak, nonatomic)NSTimer *stepperTimer;
@property (strong, nonatomic)NSDate *stepperTouchDownBegan;
@property BOOL firstStepCompleted;
@property int diameterChangeValue;

@end


@implementation StepperButton

- (void)loadImagesForButton:(StepperButton *)button withViewController:(UIViewController *)vc;

{
    vars = [VariableStore sharedVariableStore];
    _parentViewController = vc;
    
    UIImage *imageForNormal;
    UIImage *imageForHighlighted;
    UIImage *imageForDisabled;
    
    int buttonType = [self stepperButtonTypeForButton:self];
    if (buttonType == StepperButtonTypeIncrement) {
        imageForNormal = [UIImage imageNamed:@"inc-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"inc-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"inc-disabled.png"];
    } else {
        imageForNormal = [UIImage imageNamed:@"dec-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"dec-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"dec-disabled.png"];
    }
    [self setImage:imageForNormal forState:UIControlStateNormal];
    [self setImage:imageForHighlighted forState:UIControlStateHighlighted];
    [self setImage:imageForDisabled forState:UIControlStateDisabled];
    
}


- (StepperButtonType)stepperButtonTypeForButton:(StepperButton *)button
{
    int buttonType = -1;
    if (button == vars.moleViewStepperIncrement) {
        buttonType = StepperButtonTypeIncrement;
    } else if (button == vars.moleViewStepperDecrement) {
        buttonType = StepperButtonTypeDecrement;
    } else {
        NSLog(@"Don't recognize the button passed to 'stepperButtonTypeForButton:'");
    }
    return buttonType;
}


- (void)stepperButtonsHide:(BOOL)hiddenState
{
    vars.moleViewStepperDecrement.hidden = hiddenState;
    vars.moleViewStepperIncrement.hidden = hiddenState;
}


- (void)stepperTouchUpInside:(StepperButton *)sender
{
    [self.stepperTimer invalidate];
    self.stepperTimer = nil;
}


- (void)stepperTouchDragOutside:(StepperButton *)sender
{
    [self.stepperTimer invalidate];
    self.stepperTimer = nil;
}


- (void)stepperTouchDown:(StepperButton *)sender
{
    
    int buttonType = [self stepperButtonTypeForButton:sender];
    NSString *logMsg;
    
    if (buttonType == StepperButtonTypeIncrement) {
        logMsg = @"TouchDown on stepperIncrement!";
        self.diameterChangeValue = 1;
    } else {  // (buttonType == self.stepperDecrement)
        logMsg = @"TouchDown on stepperDecrement!";
        self.diameterChangeValue = -1;
    }
    self.stepperTouchDownBegan = [[NSDate alloc] init];
    self.firstStepCompleted = NO;
    self.stepperTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                         target:self
                                                       selector:@selector(respondToTimer)
                                                       userInfo:nil
                                                        repeats:YES];
}


- (void)respondToTimer
{
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.stepperTouchDownBegan];
    int elapsed = floor(interval * 10.0);
    // NSLog(@"elapsed time %i",elapsed);
    BOOL execute = NO;
    if (elapsed < 6) {
        // increment once while elapsed is < 6
        if (!self.firstStepCompleted) {
            execute = YES;
            self.firstStepCompleted = YES;
        }
    } else if (elapsed < 20) {
        // execute once each 0.3 seconds
        if (elapsed % 3 == 0) {
            execute = YES;
        }
    } else {
        // execute once each 0.1 seconds
        execute = YES;
    }
    if (execute) {
        [self.parentViewController performSelector:@selector(updateDiameterWithChangeValue:)
                                        withObject:[NSNumber numberWithInt:self.diameterChangeValue]];
    }
}


@end
