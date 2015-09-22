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
    //_moleNameLabel.text = @"Franklin D. Molesvelt";
    NSNumber* size = [mole objectForKey:@"size"];
    NSNumber* percentChange = [mole objectForKey:@"percentChange"];
    Measurement* measurement = [mole objectForKey:@"measurement"];
    NSDate* date = measurement.date;
    
    float sizeFloat = ceilf([size floatValue] * 10.0f) / 10.0f;
    
    //debug
    //NSDate* date = [mole objectForKey:@"measurement"];
    //NSNumber* size = [NSNumber numberWithFloat:2.3f];
    //NSNumber* percentChange = [NSNumber numberWithFloat:0.1f];
    
    NSString* dateString = [NSString stringWithFormat:@"%@", [self getFormatedDate:date]];
    
    if ([percentChange floatValue] > 0)
    {
        _arrowImageView.image = [UIImage imageNamed:@"arrowup"];
    }
    else if ([percentChange floatValue] < 0)
    {
        _arrowImageView.image = [UIImage imageNamed:@"arrowdown"];
    }
    else if ([percentChange floatValue] == 0)
    {
        _arrowImageView.image = [UIImage imageNamed:@"arrowNil"];
    }
    
    
    percentChange = [NSNumber numberWithFloat:fabsf([percentChange floatValue])];
    _moleSizeLabel.text = [NSString stringWithFormat:@"Size: %2.1f mm\nLast measured: %@", sizeFloat, dateString];
    _moleProgressLabel.text = [percentChange floatValue] > 0.0f ? [NSString stringWithFormat:@"%2.1f%%", [percentChange floatValue]] : @"0.0%";
    
    // Configure the view for the selected state
}

- (NSString*) getFormatedDate: (NSDate*) date;
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MMM dd, yyyy";
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

@end