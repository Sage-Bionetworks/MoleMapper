//
//  DashBoardMeasurementCell.m
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
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


#import "DashBoardMeasurementCell.h"
#import "MoleViewController.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"

@implementation DashBoardMeasurementCell

- (void)awakeFromNib {
    // Initialization code
    
    //_dbModel = [[DashboardModel alloc] init];
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
    _viewMoleBtn.layer.cornerRadius = 5; // this value vary as per your desire
    _viewMoleBtn.clipsToBounds = YES;
    if ([[[DashboardModel sharedInstance] nameForBiggestMole] isEqualToString:@"No moles measured yet!"])
    {
        _viewMoleBtn.enabled = NO;
        _viewMoleBtn.alpha = 0.5;
        _viewMoleBtn.backgroundColor = [UIColor grayColor];
    }
    else {_viewMoleBtn.enabled = YES;}
    
    float lastFloat = ceilf([[[DashboardModel sharedInstance] sizeOfBiggestMole] floatValue]);
    _offset = lastFloat / 5.0f;
    
    _secondLabel.text = [NSString stringWithFormat:@"%2.1f", _offset];
    _thirdLabel.text = [NSString stringWithFormat:@"%2.1f", _offset * 2];
    _forthLabel.text = [NSString stringWithFormat:@"%2.1f", _offset * 3];
    _fifthLabel.text = [NSString stringWithFormat:@"%2.1f", _offset * 4];
    _sixthLabel.text = [NSString stringWithFormat:@"%2.1f", lastFloat];
    
    float half = _secondLabel.bounds.size.width;
    _secondLabel.frame = [self getPositionOfLabels:lastFloat offsetFloat:_offset withHalfOfLabel:half withLabel:_secondLabel];
    _thirdLabel.frame = [self getPositionOfLabels:lastFloat offsetFloat:_offset * 2 withHalfOfLabel:half withLabel:_thirdLabel];
    _forthLabel.frame = [self getPositionOfLabels:lastFloat offsetFloat:_offset * 3 withHalfOfLabel:half withLabel:_forthLabel];
    _fifthLabel.frame = [self getPositionOfLabels:lastFloat offsetFloat:_offset * 4 withHalfOfLabel:half withLabel:_fifthLabel];
    _sixthLabel.frame = [self getPositionOfLabels:lastFloat offsetFloat:lastFloat withHalfOfLabel:half withLabel:_sixthLabel];
}

-(CGRect) getPositionOfLabels: (float) biggestFloat offsetFloat: (float) offset withHalfOfLabel: (float) half withLabel:(UILabel*) label
{
    float multiplier = _lineOfMeasurement.bounds.size.width / biggestFloat;
    NSInteger posx = _lineOfMeasurement.bounds.origin.x + offset * multiplier;
    CGRect rect = label.frame;
    rect.origin.x = posx;
    return rect;
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
    UIColor *c_bcolor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
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
    
    float lastFloat = ceilf([[[DashboardModel sharedInstance] sizeOfBiggestMole] floatValue]);
    float multiplier = _lineOfMeasurement.bounds.size.width / lastFloat;
    //multiplier = multiplier / (_offset * 10);
    //[NSNumber numberWithFloat: myfloatvalue];
    for (int i = 0; i < [dotsArray count]; ++i)
    {
        NSInteger posx = _lineOfMeasurement.bounds.origin.x + [[dotsArray objectAtIndex:i] floatValue] * multiplier;
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
    
    /* //POSSIBLE HIDE FOR LATER USE
     NSNumber *biggestSize = [[DashboardModel sharedInstance] sizeOfBiggestMole];
    if ([biggestSize integerValue] > 0)
        [self setupLabels];
    else {
        
    }*/
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
