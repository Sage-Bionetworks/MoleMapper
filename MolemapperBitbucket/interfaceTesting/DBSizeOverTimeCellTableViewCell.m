//
//  DBSizeOverTimeCellTableViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DBSizeOverTimeCellTableViewCell.h"
#import "Measurement.h"
#import "DashboardModel.h"

@implementation DBSizeOverTimeCellTableViewCell

- (void)viewDidLoad {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    NSString *key = [NSString stringWithFormat:@"%i",  (int)_idx];
    NSDictionary *mole = [_moleDictionary objectForKey:key];
    
    _moleNameLabel.text = [mole objectForKey:@"name"];
    NSNumber* size = [mole objectForKey:@"size"];
    NSNumber* percentChange = [mole objectForKey:@"percentChange"];
    //Measurement* measurement = [mole objectForKey:@"measurement"];
    //NSDate* date = measurement.date;
    
    _moleSizeLabel.text = [NSString stringWithFormat:@"%2.1f mm, April 12 2087", [size floatValue]];
    _moleProgressLabel.text = [percentChange floatValue] > 0.0f ? [NSString stringWithFormat:@"%2.1f%%", [percentChange floatValue]] : @"0.0%%";
    
    // Configure the view for the selected state
}

- (NSString*) getFormatedDate
{
    NSNumber* lastDate = [[DashboardModel sharedInstance] daysUntilNextMeasurementPeriod];//[_dbModel daysSinceLastFollowup];
    
    NSDate* date = [NSDate date];
    
    NSDateComponents* comps = [[NSDateComponents alloc]init];
    comps.day = -lastDate.integerValue;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDate* correctedDay = [calendar dateByAddingComponents:comps toDate:date options:nil];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MMMM dd";
    NSString* dateString = [formatter stringFromDate:correctedDay];
    
    return dateString;
}

@end
