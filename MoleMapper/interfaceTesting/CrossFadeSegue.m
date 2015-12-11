//
//  CrossFadeSegue.m
//  BodyMapAsImage
//
//  Created by David Reese on 7/12/13.
//  Copyright (c) 2013 Floribunda Software. All rights reserved.
//

#import "CrossFadeSegue.h"

@implementation CrossFadeSegue

- (void)perform
{
	UIViewController *source = self.sourceViewController;
	UIViewController *destination = self.destinationViewController;
    
	// Start the animation
	[UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^(void)
                     {
                         source.view.alpha = 0.0;
                     }
                     completion: ^(BOOL done)
                     {
                         // Properly present the new screen
                         [source presentViewController:destination animated:NO completion:nil];
                     }];
}

@end


//    - (void)perform
//    {
//        UIViewController *source = self.sourceViewController;
//        UIViewController *destination = self.destinationViewController;
//        
//        // Create a UIImage with the contents of the destination
//        UIGraphicsBeginImageContext(destination.view.bounds.size);
//        [destination.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *destinationImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        // Add this image as a subview to the tab bar controller
//        UIImageView *destinationImageView = [[UIImageView alloc] initWithImage:destinationImage];
//        [source.parentViewController.view addSubview:destinationImageView];
//        
//        // Scale the image down and rotate it 180 degrees (upside down)
//        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.1, 0.1);
//        CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(M_PI);
//        destinationImageView.transform = CGAffineTransformConcat(scaleTransform, rotateTransform);
//        
//        // Move the image outside the visible area
//        CGPoint oldCenter = destinationImageView.center;
//        CGPoint newCenter = CGPointMake(oldCenter.x - destinationImageView.bounds.size.width, oldCenter.y);
//        destinationImageView.center = newCenter;
//        
//        // Start the animation
//        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut
//                         animations:^(void)
//         {
//             destinationImageView.transform = CGAffineTransformIdentity;
//             destinationImageView.center = oldCenter;
//         }
//                         completion: ^(BOOL done)
//         {
//             // Remove the image as we no longer need it
//             [destinationImageView removeFromSuperview];
//             
//             // Properly present the new screen
//             [source presentViewController:destination animated:NO completion:nil];
//         }];
//    }
