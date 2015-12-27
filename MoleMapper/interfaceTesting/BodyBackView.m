//
//  BodyBackView.m
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


#import "BodyBackView.h"
#import "VariableStore.h"

@implementation BodyBackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VariableStore *vars = [VariableStore sharedVariableStore];
        self.image = [UIImage imageNamed:@"bodyBackInnerLines.png"];
        [self setUserInteractionEnabled:YES];
        
        _tagZones = [vars BuildTagZoneDictionaryAndButtonsWithStructureData:[self tagZoneStructureData] forView:self];
    }
    return self;
}


//    - (void)drawRect:(CGRect)rect
//    {
//
//    }


- (NSArray *)tagZoneStructureData
// LEGEND:
//   tzData[tagID][0] = tagID
//   tzData[tagID][1] = [originX, originY]
//   tzData[tagID][2] = titleBarText
//   tzData[tagID][3] = baseZoneID
{
    NSArray *tzData;
    tzData = @[
               
               @[@2100, @[ @83.0f, @1.22705f ], @"Head", @10],
               @[@2200, @[ @93.4414f, @51.2275f ], @"Neck", @2200],
               @[@2250, @[ @71.8076f, @75.5186f ], @"Left Upper Back", @2250],
               @[@2251, @[ @108.001f, @75.5186f ], @"Right Upper Back", @2251],
               @[@2300, @[ @71.0f, @131.1084f ], @"Left Lower Back", @300],
               @[@2301, @[ @108.0f, @131.1084f ], @"Right Lower Back", @301],
               @[@2350, @[ @62.501f, @170.1094f ], @"Left Glute", @2350],
               @[@2351, @[ @108.001f, @170.1094f ], @"Right Glute", @2351],
               @[@2400, @[ @62.501f, @219.6094f ], @"Left Upper Thigh", @40],
               @[@2401, @[ @108.001f, @219.6094f ], @"Right Upper Thigh", @40],
               @[@2450, @[ @65.5f, @254.6094f ], @"Left Lower Thigh & Knee", @45],
               @[@2451, @[ @110.5f, @254.6094f ], @"Right Lower Thigh & Knee", @45],
               @[@2500, @[ @66.5f, @298.6094f ], @"Left Upper Calf", @50],
               @[@2501, @[ @114.5f, @298.6094f ], @"Right Upper Calf", @50],
               @[@2550, @[ @69.5f, @329.1094f ], @"Left Lower Calf", @55],
               @[@2551, @[ @115.5f, @329.1094f ], @"Right Lower Calf", @55],
               @[@2600, @[ @65.0f, @357.1094f ], @"Left Ankle & Foot", @60],
               @[@2601, @[ @117.0f, @357.1094f ], @"Right Ankle & Foot", @60],
               @[@2650, @[ @50.2246f, @60.8799f ], @"Left Shoulder", @650],
               @[@2651, @[ @118.1143f, @60.8799f ], @"Right Shoulder", @651],
               @[@2700, @[ @39.5293f, @97.3447f ], @"Left Upper Arm", @700],
               @[@2701, @[ @139.75f, @97.3447f ], @"Right Upper Arm", @701],
               @[@2750, @[ @29.793f, @133.0771f ], @"Left Elbow", @750],
               @[@2751, @[ @147.7324f, @133.0771f ], @"Right Elbow", @751],
               @[@2800, @[ @19.7432f, @158.8135f ], @"Left Lower Forearm", @800],
               @[@2801, @[ @157.4688f, @158.8135f ], @"Right Lower Forearm", @801],
               @[@2850, @[ @1.48926f, @182.2344f ], @"Left Hand", @850],
               @[@2851, @[ @167.5186f, @182.2344f ], @"Right Hand", @851],
               
               ];
    return tzData;
}


@end
