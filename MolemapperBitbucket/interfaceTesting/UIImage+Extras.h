// UIImage+Alpha.h
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import <UIKit/UIKit.h>

@interface UIImage (Extras)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

//Note this category can be found here:
//http://stackoverflow.com/questions/185652/how-to-scale-a-uiimageview-proportionally

@end
