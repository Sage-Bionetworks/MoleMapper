//
//  DBSizeOverTimeCellTableViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
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


#import "DBSizeOverTimeCellTableViewCell.h"
#import "Measurement.h"
#import "DashboardModel.h"

@implementation DBSizeOverTimeCellTableViewCell

- (void)viewDidLoad {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _moleProgressLabel.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
    NSString *key = [NSString stringWithFormat:@"%i",  (int)_idx];
    NSDictionary *mole = [_moleDictionary objectForKey:key];
    
    _moleNameLabel.text = [mole objectForKey:@"name"];
    //_moleNameLabel.text = @"Franklin D. Molesvelt";
    NSNumber* size = [mole objectForKey:@"size"];
    NSNumber* percentChange = [mole objectForKey:@"percentChange"];
    Measurement* measurement = [mole objectForKey:@"measurement"];
    NSDate* date = measurement.date;
    
    float sizeFloat = [[DashboardModel sharedInstance] correctFloat:[size floatValue]];
    
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
        _arrowImageView.image = [UIImage imageNamed:@""];
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