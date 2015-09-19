//
//  BaseZone.h
//  BodyMap
//
//

#import <UIKit/UIKit.h>

typedef enum {
    ZoneStateHighlighted,
    ZoneStateNoImage,
    ZoneStateHasImage,
} ZoneState;

@interface BaseZone : NSObject

@property int baseID;
@property (nonatomic, strong) NSArray *foundationalCoordinates;  // This is needed for bezPathAtScale, and TagZone.bezPathOnImageAtScale.
@property (nonatomic, strong) UIBezierPath *bezPathAtDrawingScale;   // Path for use in creation of Button Images
@property (nonatomic, strong) UIImage *shapeForHighlighted;
@property (nonatomic, strong) UIImage *shapeForNoImage;
@property (nonatomic, strong) UIImage *shapeForHasImage;

- (BaseZone *)initWithBaseID:(int)baseID
               frameSizeAt1x:(NSArray *)sizeArray
              andCoordinates:(NSArray *)coords
              atDrawingScale:(float)drawingScale;

@end



