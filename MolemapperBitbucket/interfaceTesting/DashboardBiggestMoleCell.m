//
//  DashboardBiggestMoleCell.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardBiggestMoleCell.h"
#import "AnimationManager.h"

@implementation DashboardBiggestMoleCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //_dbModel =  [[DashboardModel alloc] init];
    
    [super setSelected:selected animated:animated];
    
    /*NSNumber* avSize = [[DashboardModel sharedInstance] sizeOfAverageMole];
    NSNumber* bgSize = [[DashboardModel sharedInstance] sizeOfBiggestMole];
    
    NSNumber* averageScale = avSize > [NSNumber numberWithFloat:1.0] ? [NSNumber numberWithFloat:1.0] : avSize;
    NSNumber* biggestScale = bgSize > [NSNumber numberWithFloat:1.0] ? [NSNumber numberWithFloat:1.0] : bgSize;
    */
    
    
    //set average from model if there is any DEBUG
    NSNumber* averageScale = [NSNumber numberWithFloat:6.7];
    NSNumber* biggestScale = [NSNumber numberWithFloat:9.2];

    _innerCircleLabel.text = [NSString stringWithFormat:@"%@ mm", averageScale];
    _outerCircleLabel.text = [NSString stringWithFormat:@"%@ mm", biggestScale];
    
    [[AnimationManager sharedInstance] scaleUIImageWithImageView:_innerCircle withDuration:0.3 withDelay:0.3 withPosFrom:0.0 withPosTo:[averageScale floatValue] * 0.1];
    [[AnimationManager sharedInstance] scaleUIImageWithImageView:_outerCircle withDuration:0.4 withDelay:0.3 withPosFrom:0.0 withPosTo:[biggestScale floatValue] * 0.1];
}

@end
