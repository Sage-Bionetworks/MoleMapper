//
//  CrossFadeSegue.m
//  BodyMapAsImage
//
//  Created by David Reese on 7/12/13.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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
