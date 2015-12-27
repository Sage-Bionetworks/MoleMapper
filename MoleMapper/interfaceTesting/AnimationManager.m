//
//  AnimationManager.m
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
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


#import "AnimationManager.h"

@implementation AnimationManager

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

-(void) scaleUIImageWithImageView: (UIImageView*) imageView withDuration:(float) durration withDelay: (float) delay withPosFrom:(float) from withPosTo:(float) to
{
    [UIView animateWithDuration:durration delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, from, from);
                     }
                     completion:^(BOOL finished){
                         if (finished){
                             
                             [UIView animateWithDuration:durration delay:delay options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, to, to);}
                                              completion:^(BOOL finished){
                                                  if (finished){
                                                      CGPoint origin = imageView.center;
                                                      CGPoint target = CGPointMake(imageView.center.x, imageView.center.y+1.1);
                                                      CABasicAnimation *bounce = [CABasicAnimation animationWithKeyPath:@"scale"];
                                                      bounce.duration = 0.2;
                                                      bounce.fromValue = [NSNumber numberWithInt:origin.y];
                                                      bounce.toValue = [NSNumber numberWithInt:target.y];
                                                      bounce.repeatCount = 2;
                                                      bounce.autoreverses = YES;
                                                      [imageView.layer addAnimation:bounce forKey:@"scale"];
                                                  }
                                              }
                              ];
                         }
                     }
     ];

}

@end
