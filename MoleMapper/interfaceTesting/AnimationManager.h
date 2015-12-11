//
//  AnimationManager.h
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationManager : NSObject

+(id)sharedInstance;

-(void) scaleUIImageWithImageView: (UIImageView*) imageView withDuration:(float) durration withDelay: (float) delay withPosFrom:(float) from withPosTo:(float) to;

@end
