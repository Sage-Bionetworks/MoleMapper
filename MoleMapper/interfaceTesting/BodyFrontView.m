//
//  BodyFrontView.m
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


#import "BodyFrontView.h"
#import "VariableStore.h"

@interface BodyFrontView ()
{
    UIScrollView *vcScrollView;
}

@end

@implementation BodyFrontView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        VariableStore *vars = [VariableStore sharedVariableStore];
        self.image = [UIImage imageNamed:@"bodyFrontInnerLines.png"];
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
               
               @[@1100, @[ @83.0f, @1.22705f ], @"Head", @10],
               @[@1200, @[ @93.4414f, @51.2275f ], @"Neck & Center Chest", @1200],
               @[@1250, @[ @71.8076f, @75.5186f ], @"Right Pectoral", @1250],
               @[@1251, @[ @108.0f, @75.5186f ], @"Left Pectoral", @1251],
               @[@1300, @[ @71.0f, @131.1084f ], @"Right Abdomen", @300],
               @[@1301, @[ @108.0f, @131.1084f ], @"Left Abdomen", @301],
               @[@1350, @[ @63.499f, @170.1084f ], @"Right Pelvis", @1350],
               @[@1351, @[ @108.0f, @170.1084f ], @"Left Pelvis", @1351],
               @[@1400, @[ @61.5f, @203.3555f ], @"Right Upper Thigh", @1400],
               @[@1401, @[ @108.0f, @203.3555f ], @"Left Upper Thigh", @1401],
               @[@1450, @[ @65.5f, @254.6094f ], @"Right Lower Thigh & Knee", @45],
               @[@1451, @[ @110.5f, @254.6094f ], @"Left Lower Thigh & Knee", @45],
               @[@1500, @[ @66.5f, @298.6094f ], @"Right Upper Calf", @50],
               @[@1501, @[ @114.5f, @298.6094f ], @"Left Upper Calf", @50],
               @[@1550, @[ @69.5f, @329.1094f ], @"Right Lower Calf", @55],
               @[@1551, @[ @115.5f, @329.1094f ], @"Left Lower Calf", @55],
               @[@1600, @[ @65.0f, @357.1094f ], @"Right Ankle & Foot", @60],
               @[@1601, @[ @117.0f, @357.1094f ], @"Left Ankle & Foot", @60],
               @[@1650, @[ @50.2246f, @60.8799f ], @"Right Shoulder", @650],
               @[@1651, @[ @118.1143f, @60.8799f ], @"Left Shoulder", @651],
               @[@1700, @[ @39.5293f, @97.3447f ], @"Right Upper Arm", @700],
               @[@1701, @[ @139.75f, @97.3447f ], @"Left Upper Arm", @701],
               @[@1750, @[ @29.793f, @133.0771f ], @"Right Upper Forearm", @750],
               @[@1751, @[ @147.7324f, @133.0771f ], @"Left Upper Forearm", @751],
               @[@1800, @[ @19.7432f, @158.8135f ], @"Right Lower Forearm", @800],
               @[@1801, @[ @157.4688f, @158.8135f ], @"Left Lower Forearm", @801],
               @[@1850, @[ @1.48926f, @182.2344f ], @"Right Hand", @850],
               @[@1851, @[ @167.5186f, @182.2344f ], @"Left Hand", @851],
               
               ];
    return tzData;
}




@end
