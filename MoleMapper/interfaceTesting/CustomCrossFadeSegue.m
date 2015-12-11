//
//  CustomCrossFadeSegue.m
//  MoleMapper
//


#import "CustomCrossFadeSegue.h"

@implementation CustomCrossFadeSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:src.navigationController.view duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    } completion:NULL];
}

@end
