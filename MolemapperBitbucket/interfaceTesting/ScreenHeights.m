//
//  ScreenHeights.m
//  MoleView
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
