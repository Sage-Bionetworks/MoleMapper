//
//  DemoKLCPopupHelper.h
//  MoleMapper
//
//  Created by Dan Webster on 9/28/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCButton.h"

//Helper class to help generate the massive amount of code needed for a KLCPopup
//with reasonable default values and approximating a ReaserchKit-like look. Still requires
//Further setup code and works best with an image at 550x440

@interface DemoKLCPopupHelper : NSObject

+(UIView *)contentViewForDemo;

+(UILabel *)labelForDemoWithFontSize:(float)fontSize andText:(NSString *)text;

+(APCButton *)buttonForDemoWithColor:(UIColor *)color withLabel:(NSString *)label  withEdgeInsets:(UIEdgeInsets)insets;

@end
