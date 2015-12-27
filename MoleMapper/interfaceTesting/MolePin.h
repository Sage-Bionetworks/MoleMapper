//
//  MolePin.h
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

#import "OBShapedButton.h"
#import "ZoneViewController.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "SMCalloutView.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"


typedef enum {
    MolePinStateNormal,
    MolePinStateSelected,
} MolePinState;

@interface MolePin : OBShapedButton <UIGestureRecognizerDelegate, SMCalloutViewDelegate>

@property float pinLocation_x;
@property float pinLocation_y;
@property int molePin_State;

@property (strong, nonatomic) NSNumber *moleID;
@property (strong, nonatomic) NSString *moleName;
@property (strong, nonatomic) Mole *mole;
@property (strong, nonatomic) Measurement *mostRecentMeasurement;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (strong, nonatomic) SMCalloutView *calloutView;


+ (id)newPinAtCenterOfScreenOnViewController:(UIViewController *)vc
                                     andView:(UIView *)view
                               andScrollView:(UIScrollView *)sv;

- (id)initMolePinAtLocation:(CGPoint)location
           onViewController:(id)vc
                    andView:(UIView *)view
              andScrollView:(UIScrollView *)sv;

- (void)setMolePinState:(int)MolePinState;


// + (id)newPinAtCenterOfScreenOnView:(UIView *)targetView;  // DTR 2013.11.26 Depricated

// + (id)newPinAtLocationX:(NSNumber *)moleLocationX atLocationY:(NSNumber *)moleLocationY onView:(UIView *)targetView;  // DTR 2013.11.26 Depricated

@end

