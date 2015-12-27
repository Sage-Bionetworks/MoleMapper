//
//  MeasuringTool.m
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


#import "MeasuringTool.h"
#import "VariableStore.h"
#import "ScreenHeights.h"
#import "MoleViewController.h"


@interface MeasuringTool ()
{
    VariableStore *vars;
}

@property float minimumLengthOfASide;

@property float measurementRingOffset;
@property float measurementRingStrokeWidth;
@property (strong, nonatomic) NSArray *measurementRingRGB;
@property float measurementRingAlpha;

@property float measurementBorderOffset;
@property float measurementBorderStrokeWidth;
@property (strong, nonatomic) NSArray *measurementBorderRGB;
@property float measurementBorderAlpha;

@property float haloInteriorOffset;
@property float haloInteriorStrokeWidth;
@property (strong, nonatomic) NSArray *haloInteriorRGB;
@property float haloInteriorAlpha;

@property float haloExteriorOffset;
@property float haloExteriorStrokeWidth;
@property (strong, nonatomic) NSArray *haloExteriorRGB;
@property float haloExteriorAlpha;

@property float referenceMeasureDefaultDiameter;
@property float moleMeasureDefaultDiameter;

@property (strong, nonatomic) UIImage *toolImageNormal;
@property (strong, nonatomic) UIImage *toolImageHighlighted;

@property float colorModifierForHighlighted;

@property float imageLengthOfASide;
@property float imageCenter_xy;
@property float multiplier;
@property float colorModifier;
@property int controlState;
@property CGContextRef ctx;

- (void)drawAndStrokePath:(CGPathRef)path
                  withRGB:(NSArray *)arrayOfRGB
                    alpha:(float)alpha
modifyColorForHighlighted:(BOOL)colorMayBeModified
           andStrokeWidth:(float)strokeWidth;

@end


@implementation MeasuringTool

- (id)initWithType:(int)measuringToolType
       andDiameter:(float)diameter
        atLocation:(CGPoint)location
  onViewController:(id)vc
           andView:(UIView *)view
     andScrollView:(UIScrollView *)sv
{
    vars = [VariableStore sharedVariableStore];
    if (self = [super initWithFrame:CGRectZero])
    {
        [self loadProperties];
        _parentViewController = vc;
        _parentView = view;
        _parentScrollView = sv;  //                          XXXXXXXXXX
        _measuringToolType = measuringToolType;
        _measuringToolState = MeasuringToolStateNormal;
        
        _measuringToolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 14.0)];
        _diameter = diameter;

        if (self.measuringToolType == MeasuringToolTypeMoleMeasure)
        {
            _measuringToolLabel.text = @"Mole Measure";
            
            if (_diameter == MeasuringToolDiameterDefault)
            {
                _diameter = self.moleMeasureDefaultDiameter;
            }
        }
        else
        {  // self.measuringToolType == MeasuringToolTypeReferenceMeasure
            _measuringToolLabel.text = @"Reference Measure";
            
            if (_diameter == MeasuringToolDiameterDefault)
            {
                _diameter = self.referenceMeasureDefaultDiameter;
            }
        }
        
        _measuringToolLabel.textAlignment = NSTextAlignmentCenter;
        _measuringToolLabel.backgroundColor = [UIColor clearColor];
        _measuringToolLabel.shadowColor = [UIColor blackColor];
        _measuringToolLabel.shadowOffset = CGSizeMake(-0.5, -0.5);
        _measuringToolLabel.textColor = [UIColor whiteColor];
        _measuringToolLabel.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:self.measuringToolLabel];

        [self addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(handleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//        [self addTarget:self action:@selector(handleTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];  //                          XXXXXXXXXX
        [_panRecognizer setMinimumNumberOfTouches:1];
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelegate:(id)self];
        [self addGestureRecognizer:_panRecognizer];
        
        _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];//                          XXXXXXXXXX
        [_longPressRecognizer setMinimumPressDuration:0.1];
        [_longPressRecognizer setAllowableMovement:10];
        [_longPressRecognizer setDelegate:(id)self];
        [self addGestureRecognizer:_longPressRecognizer];
        
        [self.parentView addSubview:self];
        
        [self drawLoop];
        
        self.location_x = location.x;
        self.location_y = location.y;
        self.center = location;
    }  // End if (self = [super initWithFrame:CGRectZero])
    
    return self;
}

// NEEDED for selectThenPan behavior.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer//                          XXXXXXXXXX
{
    if ((gestureRecognizer == self.longPressRecognizer) && (otherGestureRecognizer == self.panRecognizer)){
        return YES;
    } else {
        return NO;
    }
}


#pragma mark Called by -initWithType: onView: andScrollView:
// -------------------------------------------- Called by -initWithType: onView: andScrollView: ----- BEGIN
- (void)loadProperties
{
    _minimumLengthOfASide = 50.0;
    
    _measurementRingOffset = 2.0;
    _measurementRingStrokeWidth = 1.25;
    _measurementRingRGB =  @[@1.0, @0.0, @0.0];  // Red
    _measurementRingAlpha = 0.3;
    
    _measurementBorderOffset = 6.0;
    _measurementBorderStrokeWidth = 5.0;  // stroke width should be borderOffset - 1.0
    _measurementBorderRGB = @[@1.0, @1.0, @1.0];  // White
    _measurementBorderAlpha = 0.5;
    
    _haloInteriorOffset = 8.0;
    _haloInteriorStrokeWidth = 7.0;  // stroke width should be borderOffset - 1.0
    _haloInteriorRGB = @[@1.0, @1.0, @1.0];  // White
    _haloInteriorAlpha = 0.0; //Interior ring made transparent to better observe the borders when resizing
    
    _haloExteriorOffset = 29.0;
    _haloExteriorStrokeWidth = 6.0;
    _haloExteriorRGB = @[@0.9529, @0.9098, @0.5098];  // "Golden Sunrise"
    _haloExteriorAlpha = 0.5;
    
    _referenceMeasureDefaultDiameter = 75.0;
    _moleMeasureDefaultDiameter= 20.0;
    _colorModifierForHighlighted = 0.0;
    _multiplier = 2.0;
}


- (void)setImagesForState:(int)state
{    
    if (state == MeasuringToolStateSelected) {
        [self setImage:self.toolImageNormal forState:UIControlStateNormal];
        [self setImage:self.toolImageNormal forState:UIControlStateHighlighted];
    } else {
        [self setImage:self.toolImageNormal forState:UIControlStateNormal];
        [self setImage:self.toolImageHighlighted forState:UIControlStateHighlighted];
    }
}


- (void)moveToolToScreenCenter
{
    CGPoint location = [vars locationOfScreenCenterOnView:self.parentScrollView atScale:self.parentScrollView.zoomScale];
    self.location_x = location.x;
    self.location_y = location.y;
    self.center = location;
    
}


- (void)moveToolToScreenCenterWithOffset:(CGPoint)offset
{
    CGPoint location = [vars locationOfScreenCenterOnView:self.parentScrollView atScale:self.parentScrollView.zoomScale];
    CGPoint locationWithOffset;

    locationWithOffset.x = location.x + offset.x;
    locationWithOffset.y = location.x + offset.y;
    
    self.location_x = locationWithOffset.x;
    self.location_y = locationWithOffset.y;
    self.center = locationWithOffset;
    
}
// -------------------------------------------- Called by -initWithType: onView: andScrollView: ----- END


#pragma mark Called by -drawToolImages
// -------------------------------------------- Called by -drawToolImages ----- BEGIN
- (float)calculateImageLengthOfASide  // returns the length of a side for the IMAGE (not the frame of the OBShapedButton)
{
    float lengthOfASide = self.diameter 
                        + (self.haloExteriorOffset / self.parentScrollView.zoomScale)
                        + (self.haloExteriorStrokeWidth / self.parentScrollView.zoomScale)
                        + 1.0;  // plus a little extra
    if (lengthOfASide < self.minimumLengthOfASide) {
        lengthOfASide = self.minimumLengthOfASide;
    }
    return lengthOfASide * self.multiplier * self.parentScrollView.zoomScale;
}


- (CGPathRef)createPathAtScaleWithDiameter:(float)diameter
{
    // float diameterAtScale = diameter * self.multiplier;
    float diameterAtScale = diameter * self.multiplier * self.parentScrollView.zoomScale;
    float origin_xyAtScale = self.imageCenter_xy - (diameterAtScale / 2.0);
    return CGPathCreateWithEllipseInRect(CGRectMake(origin_xyAtScale, origin_xyAtScale, diameterAtScale, diameterAtScale), NULL);
}


//    - (void)drawAndStrokePath:(CGPathRef)path withRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha andStrokeWidth:(float)strokeWidth
//    {
//        CGContextAddPath(self.ctx, path);  // Add the path
//        CGContextSetLineWidth(self.ctx, strokeWidth);  // Set the stroke width
//        UIColor *strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//        [strokeColor setStroke];
//        CGContextSetStrokeColorWithColor (self.ctx, strokeColor.CGColor); // Set the stroke color
//        CGContextDrawPath(self.ctx, kCGPathStroke);  // Draw the circle
//    }


- (void)drawAndStrokePath:(CGPathRef)path
                  withRGB:(NSArray *)arrayOfRGB
                    alpha:(float)alpha
modifyColorForHighlighted:(BOOL)colorMayBeModified
           andStrokeWidth:(float)strokeWidth
{
    CGContextAddPath(self.ctx, path);  // Add the path
    CGContextSetLineWidth(self.ctx, strokeWidth);  // Set the stroke width
    
    float colorModifier;
    if ((colorMayBeModified) && (self.controlState == UIControlStateHighlighted)) {
        colorModifier = self.colorModifierForHighlighted;
    } else {
        colorModifier = 1;
    }
    
    if (self.measuringToolState == MeasuringToolStateNormal) {  // If the measuring tool's state is normal, override the alpha and set it to 1.0
        alpha = 1.0;
    }

    float red = [arrayOfRGB[0] floatValue] * colorModifier;
    float green = [arrayOfRGB[1] floatValue] * colorModifier;
    float blue = [arrayOfRGB[2] floatValue] * colorModifier;
    UIColor *strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    [strokeColor setStroke];
    CGContextSetStrokeColorWithColor (self.ctx, strokeColor.CGColor); // Set the stroke color
    CGContextDrawPath(self.ctx, kCGPathStroke);  // Draw the circle
}

// -------------------------------------------- Called by -drawToolImages ----- END


#pragma mark Draw Loop
- (void)drawLoop
// Called by [self] -initWithType: onView: andScrollView:
// Called by [self] -handleLongPress:
// Called by [MoleViewController] -diameterChanged:
// Called by [MoleViewController] -scrollViewDidEndZooming: withView: atScale:
// Called by [MoleViewController] -moleImageTapped:
{
    [self drawToolImages];  // create images
    float meas = self.toolImageNormal.size.width / self.multiplier / self.parentScrollView.zoomScale;
    self.frame = CGRectMake(0.0, 0.0, meas, meas);  // resize button frame
    [self setImagesForState:self.measuringToolState];  // "Insert" images into button
    self.center = CGPointMake(self.location_x, self.location_y);
    
    self.measuringToolLabel.center = CGPointMake((self.frame.size.width / 2.0), -5.0);
}


- (void)drawToolImages
// Calls -calculateImageLengthOfASide
// Calls -createPathAtScaleWithDiameter:
// Calls -drawAndStrokePath: withRed: green: blue: alpha: andStrokeWidth:
{
    self.imageLengthOfASide = [self calculateImageLengthOfASide];
    self.imageCenter_xy = self.imageLengthOfASide / 2.0;
    
    float tranparentBackgroundDiameter = self.diameter;
    if (tranparentBackgroundDiameter < (self.minimumLengthOfASide)) {
        tranparentBackgroundDiameter = (self.minimumLengthOfASide);
    }

    // -------------------------------------------------------- Create the Paths for the various circles - BEGIN
    //
    // CGPathRef transparentBackgroundPath = [self createPathAtScaleWithDiameter:tranparentBackgroundDiameter - 2.0]; // TESTING
    CGPathRef transparentBackgroundPath = [self createPathAtScaleWithDiameter:tranparentBackgroundDiameter]; // transparentBackground
    
    float haloInterior_Offset = self.haloInteriorOffset / self.parentScrollView.zoomScale;
    // float haloInterior_Offset = self.haloInteriorOffset;
    CGPathRef haloInteriorPath = [self createPathAtScaleWithDiameter:self.diameter + haloInterior_Offset];
    
    float haloExterior_Offset = self.haloExteriorOffset / self.parentScrollView.zoomScale;
    // float haloExterior_Offset = self.haloExteriorOffset;
    CGPathRef haloExteriorPath = [self createPathAtScaleWithDiameter:self.diameter + haloExterior_Offset];
    
    float measurementBorder_Offset = self.measurementBorderOffset / self.parentScrollView.zoomScale;
    // float measurementBorder_Offset = self.measurementBorderOffset;
    CGPathRef measurementBorderPath = [self createPathAtScaleWithDiameter:self.diameter + measurementBorder_Offset];
    
    float measurementRing_Offset = self.measurementRingOffset / self.parentScrollView.zoomScale;
    // float measurementRing_Offset = self.measurementRingOffset;
    CGPathRef measurementRingPath = [self createPathAtScaleWithDiameter:self.diameter + measurementRing_Offset];
    //
    // -------------------------------------------------------- Create the Paths for the various circles - END

    UIImage *image;
    UIColor *fillColor;
    // float colorModifier;
    for (int i = 1; i <= 2; i++) {
        
        switch (i)
        {
            case 1:
                self.controlState = UIControlStateNormal;
                // colorModifier = 1.0;
                break;
            case 2:
                self.controlState = UIControlStateHighlighted;
                // colorModifier = 0.5;
                break;
        }
        
        UIGraphicsBeginImageContext(CGSizeMake(self.imageLengthOfASide, self.imageLengthOfASide));
        UIImage *scratchImage = UIGraphicsGetImageFromCurrentImageContext();
        [scratchImage drawAtPoint:CGPointZero];
        self.ctx = UIGraphicsGetCurrentContext();
        
//        // -------------------------------------------------------- Test fill BEGIN
//        //
//        fillColor = [UIColor colorWithWhite:1.0 alpha:0.4];
//        [fillColor setFill];
//        CGContextSetFillColorWithColor (self.ctx, fillColor.CGColor); // Set the fill color
//        CGPathRef testFill = CGPathCreateWithRect(CGRectMake(0.0,  0.0, self.imageLengthOfASide, self.imageLengthOfASide), NULL);
//        CGContextAddPath(self.ctx, testFill);  // Add the path
//        CGContextDrawPath(self.ctx, kCGPathFill);  // Draw the circle
//        //
//        // -------------------------------------------------------- Test fill END
        
        
        // -------------------------------------------------------- transparentBackground BEGIN
        //
        // fillColor = [UIColor colorWithWhite:1.0 alpha:0.3];  // TESTING
        fillColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        [fillColor setFill];
        CGContextSetFillColorWithColor (self.ctx, fillColor.CGColor); // Set the fill color
        CGContextAddPath(self.ctx, transparentBackgroundPath);  // Add the path
        CGContextDrawPath(self.ctx, kCGPathFill);  // Draw the circle
        //
        // -------------------------------------------------------- transparentBackground END
        
        
        float strokeWidth;
        if (self.measuringToolState == MeasuringToolStateSelected)
        {
            // -------------------------------------------------------- haloInterior BEGIN
            //
            // strokeWidth = self.haloInteriorStrokeWidth / self.parentScrollView.zoomScale * self.multiplier;
            strokeWidth = self.haloInteriorStrokeWidth * self.multiplier;
            //            float haloIntStroke = strokeWidth;  -- for Testing (NSLog)
            [self drawAndStrokePath:haloInteriorPath
                            withRGB:self.haloInteriorRGB
                              alpha:self.haloInteriorAlpha
          modifyColorForHighlighted:NO
                     andStrokeWidth:strokeWidth];
            //
            // -------------------------------------------------------- haloInterior END
            
            
            // -------------------------------------------------------- haloExterior BEGIN  ("Yellow Glow")
            //
            // strokeWidth = self.haloExteriorStrokeWidth / self.parentScrollView.zoomScale * self.multiplier;
            strokeWidth = self.haloExteriorStrokeWidth * self.multiplier;
            //            float haloExtStroke = strokeWidth;  -- for Testing (NSLog)
            [self drawAndStrokePath:haloExteriorPath
                            withRGB:self.haloExteriorRGB
                              alpha:self.haloExteriorAlpha
          modifyColorForHighlighted:NO
                     andStrokeWidth:strokeWidth];
            //
            // -------------------------------------------------------- haloExterior END
            
        } else {  // The measurement border is drwn only when the tool is not selected
            // -------------------------------------------------------- measurementBorder BEGIN
            //
            // strokeWidth = self.measurementBorderStrokeWidth / self.parentScrollView.zoomScale * self.multiplier;
            strokeWidth = self.measurementBorderStrokeWidth * self.multiplier;
            //        float measBorderStroke = strokeWidth;  -- for Testing (NSLog)
            [self drawAndStrokePath:measurementBorderPath
                            withRGB:self.measurementBorderRGB
                              alpha:self.measurementBorderAlpha
          modifyColorForHighlighted:YES
                     andStrokeWidth:strokeWidth];
            //
            // -------------------------------------------------------- measurementBorder END
        }  // end if (self.measuringToolState == MeasuringToolStateSelected)
        
        
        // -------------------------------------------------------- measurementRing BEGIN
        //
        // strokeWidth = self.measurementRingStrokeWidth / self.parentScrollView.zoomScale * self.multiplier;
        strokeWidth = self.measurementRingStrokeWidth * self.multiplier;
        //        float measRingStroke = strokeWidth;  -- for Testing (NSLog)
        [self drawAndStrokePath:measurementRingPath
                        withRGB:self.measurementRingRGB
                          alpha:self.measurementRingAlpha
      modifyColorForHighlighted:YES
                 andStrokeWidth:strokeWidth];
        //
        // -------------------------------------------------------- measurementRing END
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        if (self.controlState == UIControlStateNormal) {
            self.toolImageNormal = image;
        } else {
            self.toolImageHighlighted = image;
        }
        UIGraphicsEndImageContext();
        
    }  // End for i = 1 to 2
}


#pragma mark User Events

- (IBAction)handleTouchDown:(MeasuringTool *) measuringTool
{
    self.parentScrollView.panGestureRecognizer.enabled = NO;
}


- (IBAction)handleTouchUpInside:(MeasuringTool *) measuringTool
{
    self.parentScrollView.panGestureRecognizer.enabled = YES;
    self.longPressRecognizer.enabled = YES;
}

- (IBAction)handleLongPress:(UIPanGestureRecognizer *)recognizer
{
    [self.parentViewController performSelector:@selector(deselectMeasuringTools)];
    [self.parentViewController performSelector:@selector(selectMeasuringTool:) withObject:self];
    self.panRecognizer.enabled = YES;
    self.longPressRecognizer.enabled = NO;
}


- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
        if (self.measuringToolState == MeasuringToolStateSelected) {
        CGPoint translation = [recognizer translationInView:self];
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
        self.location_x = self.center.x;
        self.location_y = self.center.y;
        
    }
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
        [self handleTouchUpInside:self];
    }
}

- (BOOL)hasValidMeasurementInfo
{
    BOOL hasValidMeasurementInfo = YES;
    if (self == nil) {hasValidMeasurementInfo = NO;}
    if (self.location_x == 0.0 && self.location_y == 0.0) {hasValidMeasurementInfo = NO;}
    if (self.diameter == 0.0) {hasValidMeasurementInfo = NO;}
    return hasValidMeasurementInfo;
}

@end
