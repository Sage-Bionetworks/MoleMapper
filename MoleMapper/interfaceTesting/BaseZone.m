//
//  BaseZone.m
//  BodyMap
//
//

#import "BaseZone.h"
#import "VariableStore.h"

@interface BaseZone ()

@end


@implementation BaseZone

- (BaseZone *)initWithBaseID:(int)baseID
               frameSizeAt1x:(NSArray *)sizeArray
              andCoordinates:(NSArray *)coords
              atDrawingScale:(float)drawingScale
{
    self.baseID = baseID;                                                                                   // Assign the baseID to .baseID
    UIBezierPath *bezPath = [self buildBezPathAtDrawingWithCoordinates:coords atDrawingScale:drawingScale]; // Build the bezPath
    self.bezPathAtDrawingScale =  bezPath;                                                                  // Assign it to .bezPathAtScale
    self.shapeForHighlighted = [self buildAnImageWithBezPath:bezPath forZoneState:ZoneStateHighlighted];
    self.shapeForNoImage = [self buildAnImageWithBezPath:bezPath forZoneState:ZoneStateNoImage];
    self.shapeForHasImage = [self buildAnImageWithBezPath:bezPath forZoneState:ZoneStateHasImage];
    
    return self;
}


- (UIBezierPath *)buildBezPathAtDrawingWithCoordinates:(NSArray *)coords atDrawingScale:(float)drawingScale
{
    float x;
    float y;
    CGMutablePathRef path = CGPathCreateMutable();
    
    x = [coords[0][0] floatValue] * drawingScale;
    y = [coords[0][1] floatValue] * drawingScale;
    CGPathMoveToPoint(path, NULL, x, y);
    for (int row = 1; row < [coords count]; row++)
    {
        x = [coords[row][0] floatValue] * drawingScale;
        y = [coords[row][1] floatValue] * drawingScale;
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGPathCloseSubpath(path);

    return [UIBezierPath bezierPathWithCGPath:path];
}


- (UIImage *)buildAnImageWithBezPath:(UIBezierPath *)bezPath forZoneState:(ZoneState)zoneState

{
    UIImage *scratchImage = [UIImage imageNamed:@"transparent360x360.png"];
    UIGraphicsBeginImageContext(bezPath.bounds.size);                        // begin a graphics context of sufficient size
    [scratchImage drawAtPoint:CGPointZero];                             // draw original image into the context
    CGContextAddPath(UIGraphicsGetCurrentContext(), bezPath.CGPath);    // Add the path
    
    UIColor *fillColor;
    //UIColor *clear = [UIColor clearColor];
    switch (zoneState)
    {
        case ZoneStateHighlighted:
            // fillColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:1.0f];  // Used for Testing
            fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
            break;
        case ZoneStateNoImage:
            // fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];  // Used for Testing
            fillColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
            break;
        case ZoneStateHasImage:
            // fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];  // Used for Testing
            fillColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.01f];
            break;
        default:
            break;
    }
    
    CGContextSetFillColorWithColor (UIGraphicsGetCurrentContext(), fillColor.CGColor);// Set fill color for image
    //CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor clearColor].CGColor);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();                                        // free the context
    
    return image;
}




- (NSArray *)baseZoneStructureData  // DELETE This
// LEGEND:
//   structureData[n][0] = baseZoneID
//   structureData[n][1][0] & [n][1][1] = size
//   structureData[n][2][0][0] & [n][2][0][1] = moveTo
//   structureData[n][2][1...][0] & [n][2][1...][1] = lineTo
{
    NSArray *coords;
    
    coords = @[
               @[
                   @10,                 // 10 - Head (master)
                   @[@50.0f, @50.0f],	// Size
                   @[
                       
                       @[@50.0f, @50.0f],	// MoveTo
                       @[@0.0f, @50.0f],	// LineTo
                       @[@0.0f, @0.0f],
                       @[@50.0f, @0.0f],
                       @[@50.0f, @50.0f],
                       
                       ],
                   ],
               
               @[
                   @15,                 // 15 - Face Detail, Face Sides
                   @[@42.0f, @43.0f],	// Size
                   @[
                       
                       @[@0.0f, @43.0f],	// MoveTo
                       @[@42.0f, @43.0f],	// LineTo
                       @[@42.0f, @0.0f],
                       @[@0.0f, @0.0f],
                       @[@0.0f, @43.0f],
                       
                       ],
                   ],
               
               @[
                   @17,                 // 17 - Face Detail, Face-Front; Head Top, Back
                   @[@35.5f, @43.0f],	// Size
                   @[
                       
                       @[@35.5f, @0.0f],	// MoveTo
                       @[@0.0f, @0.0f],	// LineTo
                       @[@0.0f, @43.0f],
                       @[@35.5f, @43.0f],
                       @[@35.5f, @0.0f],
                       
                       ],
                   ],
               
               @[
                   @40,                 // 40 - Upper Thigh (back)
                   @[@45.5f, @35.0f],	// Size
                   @[
                       
                       @[@45.5f, @35.0f],	// MoveTo
                       @[@0.0f, @35.0f],	// LineTo
                       @[@0.0f, @0.0f],
                       @[@45.5f, @0.0f],
                       @[@45.5f, @35.0f],
                       
                       ],
                   ],
               
               @[
                   @45,                 // 45 - Lower Thigh & Knee
                   @[@40.0f, @44.0f],	// Size
                   @[
                       
                       @[@40.0f, @44.0f],	// MoveTo
                       @[@0.0f, @44.0f],	// LineTo
                       @[@0.0f, @0.0f],
                       @[@40.0f, @0.0f],
                       @[@40.0f, @44.0f],
                       
                       ],
                   ],
               
               @[
                   @50,                 // 50 - Upper Calf
                   @[@35.0f, @30.5f],	// Size
                   @[
                       
                       @[@35.0f, @30.5f],	// MoveTo
                       @[@0.0f, @30.5f],	// LineTo
                       @[@0.0f, @0.0f],
                       @[@35.0f, @0.0f],
                       @[@35.0f, @30.5f],
                       
                       ],
                   ],
               
               @[
                   @55,                 // 55 - Lower Calf
                   @[@31.0f, @28.0f],	// Size
                   @[
                       
                       @[@31.0f, @28.0f],	// MoveTo
                       @[@0.0f, @28.0f],	// LineTo
                       @[@0.0f, @0.0f],
                       @[@31.0f, @0.0f],
                       @[@31.0f, @28.0f],
                       
                       ],
                   ],
               
               @[
                   @60,                 // 60 - Ankle & Foot
                   @[@34.0f, @45.0f],	// Size
                   @[
                       
                       @[@34.0f, @0.0f],	// MoveTo
                       @[@0.0f, @0.0f],	// LineTo
                       @[@0.0f, @45.0f],
                       @[@34.0f, @45.0f],
                       @[@34.0f, @0.0f],
                       
                       ],
                   ],
               
               @[
                   @300,                // 300 - Abdomen, Lower Back
                   @[@37.0f, @39.0f],	// Size
                   @[
                       
                       @[@0.0f, @4.46094f],	// MoveTo
                       @[@0.0f, @39.0f],	// LineTo
                       @[@37.0f, @39.0f],
                       @[@37.0f, @0.0f],
                       @[@0.80664f, @0.0f],
                       @[@0.0f, @4.46094f],
                       
                       ],
                   ],
               
               @[
                   @301,                    // 301 - Abdomen, Lower Back
                   @[@37.0f, @39.0f],       // Size
                   @[
                       
                       @[@37.0f, @4.46094f],	// MoveTo
                       @[@37.0f, @39.0f],	// LineTo
                       @[@0.0f, @39.0f],
                       @[@0.0f, @0.0f],
                       @[@36.1934f, @0.0f],
                       @[@37.0f, @4.46094f],
                       
                       ],
                   ],
               
               @[
                   @650,                    // 650 - Shoulder
                   @[@47.6611f, @45.6953f],	// Size
                   @[
                       
                       @[@29.8516f, @21.9092f],	// MoveTo
                       @[@26.0254f, @45.6953f],	// LineTo
                       @[@0.0f, @35.2754f],
                       @[@9.80566f, @10.2275f],
                       @[@43.2168f, @0.0f],
                       @[@45.2188f, @0.0f],
                       @[@47.6611f, @14.6387f],
                       @[@29.8516f, @21.9092f],
                       
                       ],
                   ],
               
               @[
                   @651,	// 651 - Shoulder
                   @[@47.6611f, @45.6953f],	// Size
                   @[
                       
                       @[@17.8096f, @21.9092f],	// MoveTo
                       @[@21.6357f, @45.6953f],	// LineTo
                       @[@47.6611f, @35.2754f],
                       @[@37.8555f, @10.2275f],
                       @[@4.44434f, @0.0f],
                       @[@2.44238f, @0.0f],
                       @[@0.0f, @14.6387f],
                       @[@17.8096f, @21.9092f],
                       
                       ],
                   ],
               
               @[
                   @700,	// 700 - Upper Arm
                   @[@36.7207f, @46.6055f],	// Size
                   @[
                       
                       @[@28.7383f, @46.6055f],	// MoveTo
                       @[@31.0684f, @40.4463f],	// LineTo
                       @[@36.7207f, @9.23047f],
                       @[@13.6592f, @0.0f],
                       @[@0.0f, @35.7324f],
                       @[@28.7383f, @46.6055f],
                       
                       ],
                   ],
               
               @[
                   @701,	// 701 - Upper Arm
                   @[@36.7207f, @46.6055f],	// Size
                   @[
                       
                       @[@7.98242f, @46.6055f],	// MoveTo
                       @[@5.65234f, @40.4463f],	// LineTo
                       @[@0.0f, @9.23047f],
                       @[@23.0605f, @0.0f],
                       @[@36.7207f, @35.7324f],
                       @[@7.98242f, @46.6055f],
                       
                       ],
                   ],
               
               @[
                   @750,	// 750 - Upper Forearm, Elbow
                   @[@38.4746f, @36.6104f],	// Size
                   @[
                       
                       @[@28.7383f, @36.6104f],	// MoveTo
                       @[@0.0f, @25.7363f],	// LineTo
                       @[@9.73633f, @0.0f],
                       @[@38.4746f, @10.873f],
                       @[@28.7383f, @36.6104f],
                       
                       ],
                   ],
               
               @[
                   @751,	// 751 - Upper Forearm, Elbow
                   @[@38.4746f, @36.6104f],	// Size
                   @[
                       
                       @[@9.73633f, @36.6104f],	// MoveTo
                       @[@38.4746f, @25.7363f],	// LineTo
                       @[@28.7383f, @0.0f],
                       @[@0.0f, @10.873f],
                       @[@9.73633f, @36.6104f],
                       
                       ],
                   ],
               
               @[
                   @800,	// 800 - Lower Forearm
                   @[@38.7881f, @36.7227f],	// Size
                   @[
                       
                       @[@28.7383f, @36.7227f],	// MoveTo
                       @[@0.0f, @25.8486f],	// LineTo
                       @[@10.0498f, @0.0f],
                       @[@38.7881f, @10.874f],
                       @[@28.7383f, @36.7227f],
                       
                       ],
                   ],
               
               @[
                   @801,	// 801 - Lower Forearm
                   @[@38.7881f, @36.7227f],	// Size
                   @[
                       
                       @[@10.0498f, @36.7227f],	// MoveTo
                       @[@38.7881f, @25.8486f],	// LineTo
                       @[@28.7383f, @0.0f],
                       @[@0.0f, @10.874f],
                       @[@10.0498f, @36.7227f],
                       
                       ],
                   ],
               
               @[
                   @850,	// 850 - Hand
                   @[@46.9922f, @61.7402f],	// Size
                   @[
                       
                       @[@46.9912f, @30.457f],	// MoveTo
                       @[@35.1543f, @61.7393f],	// LineTo
                       @[@0.0f, @48.4395f],
                       @[@0.0f, @31.2852f],
                       @[@11.8389f, @0.0f],
                       @[@46.9922f, @13.3018f],
                       @[@46.9912f, @30.457f],
                       
                       ],
                   ],
               
               @[
                   @851,	// 851 - Hand
                   @[@46.9922f, @61.7402f],	// Size
                   @[
                       
                       @[@0.0f, @30.457f],	// MoveTo
                       @[@11.8379f, @61.7393f],	// LineTo
                       @[@46.9922f, @48.4395f],
                       @[@46.9912f, @31.2852f],
                       @[@35.1533f, @0.0f],
                       @[@0.0f, @13.3018f],
                       @[@0.0f, @30.457f],
                       
                       ],
                   ],
               
               @[
                   @1200,	// 1200 - Neck & Center Chest (front)
                   @[@29.1172f, @60.915f],	// Size
                   @[
                       
                       @[@2.00195f, @9.65234f],	// MoveTo
                       @[@10.5547f, @60.915f],	// LineTo
                       @[@18.5625f, @60.915f],
                       @[@27.1152f, @9.65234f],
                       @[@29.1172f, @9.65234f],
                       @[@29.1172f, @0.0f],
                       @[@0.0f, @0.0f],
                       @[@0.0f, @9.65234f],
                       @[@2.00195f, @9.65234f],
                       
                       ],
                   ],
               
               @[
                   @1250,	// 1250 - Pectorals (front)
                   @[@36.1934f, @55.5898f],	// Size
                   @[
                       
                       @[@0.0f, @55.5898f],	// MoveTo
                       @[@36.1934f, @55.5898f],	// LineTo
                       @[@36.1934f, @36.624f],
                       @[@32.1895f, @36.624f],
                       @[@26.0781f, @0.0f],
                       @[@8.26953f, @7.27051f],
                       @[@0.0f, @55.5898f],
                       
                       ],
                   ],
               
               @[
                   @1251,	// 1251 - Pectorals (front)
                   @[@36.1934f, @55.5898f],	// Size
                   @[
                       
                       @[@36.1934f, @55.5898f],	// MoveTo
                       @[@0.0f, @55.5898f],	// LineTo
                       @[@0.0f, @36.624f],
                       @[@4.00391f, @36.624f],
                       @[@10.1133f, @0.0f],
                       @[@27.9238f, @7.27051f],
                       @[@36.1934f, @55.5898f],
                       
                       ],
                   ],
               
               @[
                   @1350,	// 1350 - Pelvis (front) **DTR 2013.08.22 Changed coords to "Close the Gap"
                   @[@44.5f, @49.8569f],	// Size
                   @[
                       
                       @[@44.5f, @49.8569f],  // MoveTo
                       @[@0.0f, @33.2471f],   // LineTo
                       @[@7.5f, @0.0f],
                       @[@44.5f, @0.0f],
                       @[@44.5f, @49.8569f],
                       
                       ],
                   ],
               
               @[
                   @1351,	// 1351 - Pelvis (front) **DTR 2013.08.22 Changed coords to "Close the Gap"
                   @[@44.5f, @49.8569f],	// Size
                   @[
                       
                       @[@0.0f, @49.8569f],  // MoveTo
                       @[@44.5, @33.2471f],  // LineTo
                       @[@37.0f, @0.0f],
                       @[@0.0f, @0.0f],
                       @[@0.0f, @49.8569f],
                       
                       ],
                   ],
               
               @[
                   @1400,	// 1400 - Upper Thigh (front) **DTR 2013.08.22 Changed coords to "Close the Gap"
                   @[@46.5f, @51.2539f],	// Size
                   @[
                       
                       @[@46.5f, @16.6279f],  // MoveTo
                       @[@46.5f, @51.2539f],  // LineTo
                       @[@0.0f, @51.2539f],
                       @[@0.0f, @0.0f],
                       @[@2.0f, @0.0f],
                       @[@46.5f, @16.6279f],
                       
                       ],
                   ],
               
               @[
                   @1401,	// 1401 - Upper Thigh (front) **DTR 2013.08.22 Changed coords to "Close the Gap"
                   @[@46.5f, @51.2539f],	// Size
                   @[
                       
                       @[@0.0f, @16.6279f],  // MoveTo
                       @[@0.0f, @51.2539f],  // LineTo
                       @[@46.5f, @51.2539f],
                       @[@46.5f, @0.0f],
                       @[@44.5f, @0.0f],
                       @[@0.0f, @16.6279f],
                       
                       ],
                   ],
               
               @[
                   @2200,	// 2200 - Neck (back)
                   @[@29.1172f, @24.291f],	// Size
                   @[
                       
                       @[@24.6729f, @24.291f],	// MoveTo
                       @[@27.1162f, @9.65234f],	// LineTo
                       @[@29.1182f, @9.65234f],
                       @[@29.1172f, @0.0f],
                       @[@0.0f, @0.0f],
                       @[@0.00098f, @9.65234f],
                       @[@2.00293f, @9.65234f],
                       @[@4.44434f, @24.291f],
                       @[@24.6729f, @24.291f],
                       
                       ],
                   ],
               
               @[
                   @2250,	// 2250 - Upper Back (back)
                   @[@36.1934f, @55.5898f],	// Size
                   @[
                       
                       @[@36.1934f, @0.0f],	// MoveTo
                       @[@26.0791f, @0.0f],	// LineTo
                       @[@8.26953f, @7.27051f],
                       @[@0.0f, @55.5898f],
                       @[@36.1934f, @55.5898f],
                       @[@36.1934f, @0.0f],
                       
                       ],
                   ],
               
               @[
                   @2251,	// 2251 - Upper Back (back)
                   @[@36.1934f, @55.5898f],	// Size
                   @[
                       
                       @[@0.0f, @0.0f],	// MoveTo
                       @[@10.1133f, @0.0f],	// LineTo
                       @[@27.9238f, @7.27051f],
                       @[@36.1934f, @55.5898f],
                       @[@0.0f, @55.5898f],
                       @[@0.0f, @0.0f],
                       
                       ],
                   ],
               
               @[
                   @2350,	// 2350 - Glute (back)
                   @[@45.5f, @49.5f],	// Size
                   @[
                       
                       @[@8.5f, @0.0f],	// MoveTo
                       @[@45.5f, @0.0f],	// LineTo
                       @[@45.5f, @49.5f],
                       @[@0.0f, @49.5f],
                       @[@0.0f, @31.7139f],
                       @[@8.5f, @0.0f],
                       
                       ],
                   ],
               
               @[
                   @2351,	// 2351 - Glute (back)
                   @[@45.5f, @49.5f],	// Size
                   @[
                       
                       @[@37.0f, @0.0f],	// MoveTo
                       @[@0.0f, @0.0f],	// LineTo
                       @[@0.0f, @49.5f],
                       @[@45.5f, @49.5f],
                       @[@45.5f, @31.7139f],
                       @[@37.0f, @0.0f],
                       
                       ]
                   ]
               ];				// end of baseZoneCoordinates array
    
    
    return coords;
}


@end
