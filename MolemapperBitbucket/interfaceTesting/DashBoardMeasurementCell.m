//
//  DashBoardMeasurementCell.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashBoardMeasurementCell.h"
#import "MoleViewController.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"

@implementation DashBoardMeasurementCell

- (void)awakeFromNib {
    // Initialization code
    
    //_dbModel = [[DashboardModel alloc] init];
    
    _viewMoleBtn.layer.cornerRadius = 5; // this value vary as per your desire
    _viewMoleBtn.clipsToBounds = YES;
    
    }

- (void)setupLabels
{
    NSString* biggestMoleName = [[DashboardModel sharedInstance] nameForBiggestMole];
    NSString* zoneMoleName = [[DashboardModel sharedInstance] zoneNameForBiggestMole];
    
    //debug version
    //NSString* biggestMoleName = @"Holy Mollie";
    //NSString* zoneMoleName = @"left upper arm";
    
    _biggestMoleLabel.text = biggestMoleName;
    _locatedMoleLabel.text = @"";
    
    if (![biggestMoleName isEqualToString:@"No moles measured yet!"])
    {
        _biggestMoleLabel.text = [NSString stringWithFormat:@"Your biggest mole is %@ and is", biggestMoleName];
        _locatedMoleLabel.text = [NSString stringWithFormat:@"located in the %@ zone.", zoneMoleName];
        
        [self updateStringColorWithLabel:_biggestMoleLabel withString:biggestMoleName];
        [self updateStringColorWithLabel:_locatedMoleLabel withString:zoneMoleName];
    }
}

- (void) updateStringColorWithLabel:(UILabel*) label withString:(NSString*) string
{
    
    
    UIColor *c_bcolor = [UIColor colorWithRed:0 / 255.0 green:171.0 / 255.0 blue:235.0 / 255.0 alpha:1.0];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: label.attributedText];
    
    NSRange range = [text.string rangeOfString:string];
    if (range.location == NSNotFound) {
        NSLog(@"string was not found");
    } else {
        [text addAttribute:NSForegroundColorAttributeName
                     value:c_bcolor
                     range:NSMakeRange(range.location, [string length])];
        [label setAttributedText: text];
    }
}

- (void)createDotsOnBar
{
    NSArray* dotsArray = [[DashboardModel sharedInstance] allMoleMeasurements];// [_dbModel allMoleMeasurements];
    for (int i = 0; i < [dotsArray count]; ++i)
    {
        [[_dotSubviews objectAtIndex:i] removeFromSuperview];
    }
    //debug version
    /*NSArray* dotsArray = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.3],
                          [NSNumber numberWithFloat:1.1],
                          [NSNumber numberWithFloat:3.3],
                          [NSNumber numberWithFloat:2.9],
                          [NSNumber numberWithFloat:4.9],
                          [NSNumber numberWithFloat:4.5],
                          [NSNumber numberWithFloat:6.1],
                          [NSNumber numberWithFloat:6.2],
                          [NSNumber numberWithFloat:9.4],
                          nil];*/
    
    float multiplier = _lineOfMeasurement.bounds.size.width / 10;
    //[NSNumber numberWithFloat: myfloatvalue];
    for (int i = 0; i < [dotsArray count]; ++i)
    {
        NSInteger posx = [[dotsArray objectAtIndex:i] floatValue] * multiplier;
        UIImageView *myImage = [[UIImageView alloc] initWithFrame:CGRectMake(posx, 95, 3, 3)];
        myImage.image = [UIImage imageNamed:@"dot.png"];
        [_dotSubviews addObject:myImage];
        [self addSubview:myImage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //_dbModel = [[DashboardModel alloc] init];
    
    [self createDotsOnBar];
    [self setupLabels];
}

- (IBAction)presentMoleViewController:(UIButton *)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    MoleViewController *moleViewController = (MoleViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MoleViewController"];
    
    Measurement *measurement = [[DashboardModel sharedInstance] measurementForBiggestMole];
    Measurement *mostRecent = [Measurement getMostRecentMoleMeasurementForMole:measurement.whichMole withContext:[[DashboardModel sharedInstance] context]];
    moleViewController.mole = measurement.whichMole;
    moleViewController.moleID = measurement.whichMole.moleID;
    moleViewController.moleName = [[DashboardModel sharedInstance] nameForBiggestMole];
    moleViewController.context = [[DashboardModel sharedInstance] context];
    moleViewController.zoneID = measurement.whichMole.whichZone.zoneID;
    
    NSNumber *zoneIDForSegue = @([measurement.whichMole.whichZone.zoneID intValue]);
    
    moleViewController.zoneTitle = [Zone zoneNameForZoneID:zoneIDForSegue];
    moleViewController.measurement = mostRecent;
    
    moleViewController.isPresentView = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:moleViewController];
    [_dashBoardViewController presentViewController:navigationController animated:YES completion:nil];
}
@end
