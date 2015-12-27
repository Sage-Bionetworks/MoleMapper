//
//  DashboardBiggestMoleCell.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
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


#import "DashboardBiggestMoleCell.h"
#import "AnimationManager.h"

@implementation DashboardBiggestMoleCell

- (void)awakeFromNib {
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //_dbModel =  [[DashboardModel alloc] init];
    
    [super setSelected:selected animated:animated];
    
    NSNumber* avSize = [[DashboardModel sharedInstance] sizeOfAverageMole];
    NSNumber* bgSize = [[DashboardModel sharedInstance] sizeOfBiggestMole];
    
    float avRounded = [[DashboardModel sharedInstance] correctFloat:[avSize floatValue]];
    float bgRounded = [[DashboardModel sharedInstance] correctFloat:[bgSize floatValue]];
    
    NSNumber* biggestScale = [NSNumber numberWithFloat:1.0f];
    NSNumber* averageScale = [NSNumber numberWithFloat:(float)[avSize floatValue]/(float)[bgSize floatValue]];

    //set average from model if there is any DEBUG
    //NSNumber* averageScale = [NSNumber numberWithFloat:6.7];
    //NSNumber* biggestScale = [NSNumber numberWithFloat:9.2];
    _innerCircleLabel.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    _outerCircleLabel.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    _innerCircleLabel.text = [NSString stringWithFormat:@"%2.1f mm", avRounded];
    _outerCircleLabel.text = [NSString stringWithFormat:@"%2.1f mm", bgRounded];
    
    [[AnimationManager sharedInstance] scaleUIImageWithImageView:_outerCircle withDuration:0.4 withDelay:0.3 withPosFrom:0.0 withPosTo:[biggestScale floatValue]];
    [[AnimationManager sharedInstance] scaleUIImageWithImageView:_innerCircle withDuration:0.3 withDelay:0.3 withPosFrom:0.0 withPosTo:[averageScale floatValue]];
    
}

@end
