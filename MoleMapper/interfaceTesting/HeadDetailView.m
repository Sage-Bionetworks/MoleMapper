//
//  HeadDetailView.m
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


#import "HeadDetailView.h"
#import "VariableStore.h"

@implementation HeadDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VariableStore *vars = [VariableStore sharedVariableStore];
        self.image = [UIImage imageNamed:@"headDetail.png"];
        [self setUserInteractionEnabled:YES];
        
        UIButton *backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect backgroundFrame = self.frame;
        backgroundFrame.origin.y -= 50;
        backgroundFrame.size.height += 50;
        
        backgroundButton.frame = backgroundFrame;
        [self addSubview:backgroundButton];
        [backgroundButton addTarget:vars.myViewController
                             action:@selector(backgroundTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        
        _tagZones = [vars BuildTagZoneDictionaryAndButtonsWithStructureData:[self tagZoneStructureData] forView:self];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}


- (NSArray *)tagZoneStructureData
// LEGEND:
//   tzData[tagID][0] = tagID
//   tzData[tagID][1] = [originX, originY]
//   tzData[tagID][2] = titleBarText
//   tzData[tagID][3] = baseZoneID
{
    NSArray *tzData;
    tzData = @[
               
               @[@3150, @[ @43.25f, @102.5f ], @"Face: Right Side", @15],
               @[@3151, @[ @130.75f, @102.5f ], @"Face: Left Side", @15],
               @[@3170, @[ @90.25f, @54.5f ], @"Top of Head", @17],
               @[@3171, @[ @90.25f, @102.5f ], @"Face: Front", @17],
               @[@3172, @[ @90.25f, @150.5f ], @"Back of Head", @17],
               
               ];
    return tzData;
}

@end
