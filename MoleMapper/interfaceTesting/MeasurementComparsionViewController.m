//
//  MeasurementComparsionViewController.m
//
//  Created by Dan Webster on 10/29/13.
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


#import "MeasurementComparsionViewController.h"
#import "UIImage+Extras.h"
#import "Measurement+MakeAndMod.h"
#import "Measurement.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import "DashboardModel.h"

@interface MeasurementComparsionViewController () <UIScrollViewDelegate>

@end

@implementation MeasurementComparsionViewController

@synthesize moleMeasurement;

-(UIImage *)measurementImage
{
    UIImage *rawImage;
    if (!_measurementImage)
    {
        rawImage = [Measurement imageForMeasurement:self.moleMeasurement];
        CGImageRef cgref = [rawImage CGImage];
        CIImage *cim = [rawImage CIImage];
        if (cim == nil && cgref == NULL)
        {
            //if nothing from core data, then load up the default
            rawImage = [UIImage imageNamed:@"noPhotoYetImage.png"];
        }

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        _measurementImage = [rawImage imageByScalingProportionallyToSize:CGSizeMake(screenWidth, screenHeight)];
    }
    return _measurementImage;
}

-(UIImageView *)measurementImageView
{
    if (!_measurementImageView) _measurementImageView = [[UIImageView alloc] initWithImage:self.measurementImage];
    _measurementImageView.userInteractionEnabled = YES;
    return _measurementImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.measurementScrollView = scrollview;
    [self.view addSubview:scrollview];
    self.automaticallyAdjustsScrollViewInsets = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateDateAndMeasurementField];
    [self.measurementScrollView addSubview:self.measurementImageView];
    self.measurementScrollView.contentSize = self.measurementImage.size;
    self.measurementScrollView.minimumZoomScale = 0.75;
    self.measurementScrollView.maximumZoomScale = 10.0;
    self.measurementScrollView.zoomScale = 1.0;
    self.measurementScrollView.delegate = self;
}

-(void)updateDateAndMeasurementField
{
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.measurementImageView.center.x - 60, 75, 120, 30)];
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:9];
    dateLabel.backgroundColor=[UIColor whiteColor];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.numberOfLines = 2;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSString *stringFromDate = [formatter stringFromDate:self.moleMeasurement.date];
    stringFromDate = [stringFromDate stringByAppendingString:@"\nMole Size: "];
    
    float roundedDiameter = [[DashboardModel sharedInstance] correctFloat:[self.moleMeasurement.absoluteMoleDiameter floatValue]];
    NSString* formattedSize = [NSString stringWithFormat:@"%.1f",roundedDiameter];
    
    stringFromDate = [stringFromDate stringByAppendingString:formattedSize];
    stringFromDate = [stringFromDate stringByAppendingString:@" mm"];
    dateLabel.text = stringFromDate;
    [self.measurementImageView addSubview:dateLabel];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.measurementImageView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
