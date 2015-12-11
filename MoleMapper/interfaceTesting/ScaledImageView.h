//
//  ScaledImageView.h
//  MoleView
//
//

#import <UIKit/UIKit.h>

@interface ScaledImageView : UIImageView

+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName andScreenObjects:(NSArray *)objectNames;

+ (UIImageView *)imageViewWithImage:(UIImage *)image andScreenObjects:(NSArray *)objectNames;

@end
