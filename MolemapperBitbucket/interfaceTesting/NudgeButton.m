//
//  NudgeButton.m
//  MoleView
//
//

#import "NudgeButton.h"
#import "VariableStore.h"


@interface NudgeButton ()
{
    VariableStore *vars;
}
@property (strong,nonatomic)UIViewController *parentViewController;
@property (weak, nonatomic)NSTimer *nudgeTimer;
@property (strong, nonatomic)NSDate *nudgeTouchDownBegan;
@property BOOL firstNudgeCompleted;
@property NSArray *locationChangeValues;

@end

@implementation NudgeButton

- (void)loadImagesForButton:(NudgeButton *)button withViewController:(UIViewController *)vc;

{
    vars = [VariableStore sharedVariableStore];
    _parentViewController = vc;
    
    UIImage *imageForNormal;
    UIImage *imageForHighlighted;
    UIImage *imageForDisabled;
    
    int buttonType = [self nudgeButtonTypeForButton:self];
    if (buttonType == NudgeButtonTypeUp) {
        imageForNormal = [UIImage imageNamed:@"up-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"up-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"up-disabled.png"];
    } else if (buttonType == NudgeButtonTypeRight) {
        imageForNormal = [UIImage imageNamed:@"rt-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"rt-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"rt-disabled.png"];
    } else if (buttonType == NudgeButtonTypeDown) {
        imageForNormal = [UIImage imageNamed:@"dn-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"dn-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"dn-disabled.png"];
    } else {  // buttonType == NudgeButtonTypeLeft)
        imageForNormal = [UIImage imageNamed:@"lt-normal.png"];
        imageForHighlighted = [UIImage imageNamed:@"lt-highlighted.png"];
        imageForDisabled = [UIImage imageNamed:@"lt-disabled.png"];
    }
    
    [self setImage:imageForNormal forState:UIControlStateNormal];
    [self setImage:imageForHighlighted forState:UIControlStateHighlighted];
    [self setImage:imageForDisabled forState:UIControlStateDisabled];
    
}


- (NudgeButtonType)nudgeButtonTypeForButton:(NudgeButton *)button
{
    int buttonType = -1;
    if (button == vars.moleViewNudgeUp) {
        buttonType = NudgeButtonTypeUp;
    } else if (button == vars.moleViewNudgeRight) {
        buttonType = NudgeButtonTypeRight;
    } else if (button == vars.moleViewNudgeDown) {
        buttonType = NudgeButtonTypeDown;
    } else if (button == vars.moleViewNudgeLeft) {
        buttonType = NudgeButtonTypeLeft;
    } else {
        NSLog(@"Don't recognize the button passed to 'stepperButtonTypeForButton:'");
    }
    return buttonType;
}


- (void)nudgeButtonsHide:(BOOL)hiddenState
{
    vars.moleViewNudgeUp.hidden = hiddenState;
    vars.moleViewNudgeRight.hidden = hiddenState;
    vars.moleViewNudgeDown.hidden = hiddenState;
    vars.moleViewNudgeLeft.hidden = hiddenState;
}


- (void)nudgeTouchUpInside:(NudgeButton *)sender
{
    [self.nudgeTimer invalidate];
    self.nudgeTimer = nil;
}


- (void)nudgeTouchDragOutside:(NudgeButton *)sender
{
    [self.nudgeTimer invalidate];
    self.nudgeTimer = nil;
}


- (void)nudgeTouchDown:(NudgeButton *)sender
{
    int buttonType = [self nudgeButtonTypeForButton:self];
    NSString *logMsg;
    
    if (buttonType == NudgeButtonTypeUp) {
        logMsg = @"TouchDown on nudgeUp!";
        self.locationChangeValues = @[@0.0, @-1.0];
    } else if (buttonType == NudgeButtonTypeRight) {
        logMsg = @"TouchDown on nudgeRight!";
        self.locationChangeValues = @[@1.0, @0.0];
    } else if (buttonType == NudgeButtonTypeDown) {
        logMsg = @"TouchDown on nudgeDown!";
        self.locationChangeValues = @[@0.0, @1.0];
    } else {  // buttonType == NudgeButtonTypeLeft)
        logMsg = @"TouchDown on nudgeLeft!";
        self.locationChangeValues = @[@-1.0, @0.0];
    }
    self.nudgeTouchDownBegan = [[NSDate alloc] init];
    self.firstNudgeCompleted = NO;
    self.nudgeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(respondToTimer)
                                                     userInfo:nil
                                                      repeats:YES];
}


- (void)respondToTimer
{
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval interval = [now timeIntervalSinceDate:self.nudgeTouchDownBegan];
    int elapsed = floor(interval * 10.0);
    BOOL execute = NO;
    if (elapsed < 6) {
        // increment once while elapsed is < 6
        if (!self.firstNudgeCompleted) {
            execute = YES;
            self.firstNudgeCompleted = YES;
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
        [self.parentViewController performSelector:@selector(updateLocationWithChangeValue:)
                                        withObject:self.locationChangeValues];
    }
}


@end
