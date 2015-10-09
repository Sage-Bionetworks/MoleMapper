//
//  MeasurementComparsionViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 10/29/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
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
