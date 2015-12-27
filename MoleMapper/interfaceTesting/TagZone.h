//
//  TagZone.h
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

#import <Foundation/Foundation.h>
#import "OBShapedButton.h"
#import "BaseZone.h"

@interface TagZone : NSObject

@property int tagID;                                                // structureData[n][0]
@property int baseID;                                           // structureData[n][3]
@property (nonatomic, strong) BaseZone *baseZonePtr;                       // Calc'd
@property CGRect frameAtScale;                                      // Calc'd
@property (nonatomic, strong) NSArray *foundationalOnImageOrigin;                  // structureData[n][2][0] & [n][2][1]
@property (nonatomic, strong) UIBezierPath *bezPathAtDrawingScale;    // Calc'd
@property (nonatomic, strong) NSString *titleBarText;                 // structureData[n][2]
@property (nonatomic, strong) OBShapedButton *button;







- (TagZone *)initWithTagID:(int)tagID
                  baseZone:(BaseZone *)baseZonePtr
              originAt1x:(NSArray *)originArray
         andTitleBarText:(NSString *)titleText
          atDrawingScale:(float)drawingScale;

@end


//               @[@1200, @[ @84.8037f, @45.0005f ], @"Neck & Center Chest", @1200],