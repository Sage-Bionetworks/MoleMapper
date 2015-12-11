//
//  ScaledImageView.m
//  MoleView
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
