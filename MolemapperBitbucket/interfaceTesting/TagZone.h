//
//  TagZone.h
//  BodyMap
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