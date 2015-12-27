//
//  ScaledImageView.m
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


#import "ScaledImageView.h"
#import "ScreenHeights.h"

@implementation ScaledImageView

+ (UIImageView *)imageViewWithImage:(UIImage *)image andScreenObjects:(NSArray *)objectNames;
{
    UIImageView *imageView = [[ScaledImageView alloc] initWithImage:image
                                                   andScreenObjects:(NSArray *)objectNames];
    return imageView;
}


+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName andScreenObjects:(NSArray *)objectNames;
{
    UIImageView *imageView = [[ScaledImageView alloc] initWithImageNamed:(NSString *)imageName
                                                        andScreenObjects:(NSArray *)objectNames];
    return imageView;
}

- (UIImageView *)initWithImage:(UIImage *)image andScreenObjects:(NSArray *)objectNames;
{
    ScaledImageView *imageView;
    
    
    // Calculate the dimensions of the View Controller's scrollView in Portrait and Landsacpe mode
    NSArray * portraitAndLandscapeHeights = [ScreenHeights calculateWithObjects:(NSArray *)objectNames];
    float scrollViewHeightInPortrait = [portraitAndLandscapeHeights[0] floatValue];
    float scrollViewHeightInLandscape = [portraitAndLandscapeHeights[1] floatValue];
    
    CGSize imgSize = image.size;
    CGSize mainScreenSize = [[UIScreen mainScreen] bounds].size;
    
    // Find the largest scale for the image, based on the above scrollView dimensions BEGIN
    // Create an array of potential imageScales
    NSArray *imgScales = @[[NSNumber numberWithFloat: scrollViewHeightInPortrait / imgSize.height],  // heightScale, Portrait
                           [NSNumber numberWithFloat: mainScreenSize.width / imgSize.width],    // widthScale, Portrait
                           [NSNumber numberWithFloat: mainScreenSize.height / imgSize.width],   // heightScale, Landsacpe
                           [NSNumber numberWithFloat: scrollViewHeightInLandscape / imgSize.height]    // widthScale, Landscape
                           ];
    // Walk down the imgeScales array, looking for the largest scale
    float imgScale = 0.0;
    NSNumber *scale;
    for (scale in imgScales) {  // Find the largest of the scales for image
        if ([scale floatValue] > imgScale) {
            imgScale = [scale floatValue];
        }
    }
    // Find the largest scale for the image, based on the above scrollView dimensions END
    
    float imgWidth = image.size.width * imgScale;  // calculate the size of the frame containing image
    float imgHeight = image.size.height * imgScale;
    
    CGRect imgViewFrame = CGRectMake(0.0, 0.0, imgWidth, imgHeight);  // create a frame that will hold the scaled image
    imageView = [[ScaledImageView alloc] initWithFrame:imgViewFrame]; // init an ImageView to hold the image
    
    imageView.image = image;  // "Stuff" the image into the imageview
    imageView.userInteractionEnabled = YES;
    
    return imageView;
}


- (UIImageView *)initWithImageNamed:(NSString *)imageName andScreenObjects:(NSArray *)objectNames;
{    
    ScaledImageView *imageView;
    
    
    // Calculate the dimensions of the View Controller's scrollView in Portrait and Landsacpe mode
    NSArray * portraitAndLandscapeHeights = [ScreenHeights calculateWithObjects:(NSArray *)objectNames];
    float scrollViewHeightInPortrait = [portraitAndLandscapeHeights[0] floatValue];
    float scrollViewHeightInLandscape = [portraitAndLandscapeHeights[1] floatValue];
    
    UIImage *image = [UIImage imageNamed:imageName];
    CGSize imgSize = image.size;
    CGSize mainScreenSize = [[UIScreen mainScreen] bounds].size;
    
    // Find the largest scale for the image, based on the above scrollView dimensions BEGIN
    // Create an array of potential imageScales
    NSArray *imgScales = @[[NSNumber numberWithFloat: scrollViewHeightInPortrait / imgSize.height],  // heightScale, Portrait
                           [NSNumber numberWithFloat: mainScreenSize.width / imgSize.width],    // widthScale, Portrait
                           [NSNumber numberWithFloat: mainScreenSize.height / imgSize.width],   // heightScale, Landsacpe
                           [NSNumber numberWithFloat: scrollViewHeightInLandscape / imgSize.height]    // widthScale, Landscape
                           ];
    // Walk down the imgeScales array, looking for the largest scale
    float imgScale = 0.0;
    NSNumber *scale;
    for (scale in imgScales) {  // Find the largest of the scales for image
        if ([scale floatValue] > imgScale) {
            imgScale = [scale floatValue];
        }
    }
    // Find the largest scale for the image, based on the above scrollView dimensions END    
    
    float imgWidth = image.size.width * imgScale;  // calculate the size of the frame containing image
    float imgHeight = image.size.height * imgScale;
    
    CGRect imageViewFrame = CGRectMake(0.0, 0.0, imgWidth, imgHeight);  // create a frame that will hold the scaled image
    imageView = [[ScaledImageView alloc] initWithFrame:imageViewFrame]; // init an ImageView to hold the image

    imageView.image = image;  // "Stuff" the image into the imageview
    imageView.userInteractionEnabled = YES;

    return imageView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
