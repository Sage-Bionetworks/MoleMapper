//
//  ScreenHeights.m
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


#import "ScreenHeights.h"

@implementation ScreenHeights

+ (NSArray *)calculateWithObjects:(NSArray *)objectNames
{
    //                                        KEY                   Portrait   Landscape
    NSDictionary *objectNamesAndHeights = @{@"iPhoneStatusBar" :  @[ @20.0,     @20.0],
                                            @"iPhoneNavBar" :     @[ @44.0,     @32.0],
                                            @"iPhoneTabBar" :     @[ @49.0,     @49.0],
                                            @"iPhoneToolBar" :    @[ @44.0,     @44.0],
                                            };
    
    CGSize mainScreenSize = [[UIScreen mainScreen] bounds].size;
    
    float totalHeightPortrait = mainScreenSize.height;  // Assign mainScreen height to totalHeightPortrait
    float totalHeightlandscape = mainScreenSize.width;  // Assign mainScreen width to totalHeightLandscape
    NSMutableArray *heightsPortaitAndLandscape;
    NSString *name;
    for (name in objectNames) {
        heightsPortaitAndLandscape = [objectNamesAndHeights objectForKey:name];  // Find the cooresponding key for the selected name
        if (heightsPortaitAndLandscape != nil) {  //                                if the key is found...
            totalHeightPortrait -= [heightsPortaitAndLandscape[0] floatValue];   // subtract the portrait and landscape heights
            totalHeightlandscape -= [heightsPortaitAndLandscape[1] floatValue];
        }
    }
    NSNumber *portraitHeight = [NSNumber numberWithFloat:totalHeightPortrait];
    NSNumber *landscapeHeight = [NSNumber numberWithFloat:totalHeightlandscape];
    
    return @[portraitHeight, landscapeHeight];  // Return the calculated landscape and portrait heights
}

@end
