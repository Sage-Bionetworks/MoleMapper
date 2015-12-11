//
//  AnimationManager.m
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
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
