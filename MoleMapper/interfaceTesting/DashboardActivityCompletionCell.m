//
//  DashboardActivityCompletionCell.m
//  UCSF Pride
//
//  Created by Christian Curiel on 5/17/15.
//  Copyright (c) 2015 Analog Republic. All rights reserved.
//

#import "DashboardActivityCompletionCell.h"
#import "PopupManager.h"

@implementation DashboardActivityCompletionCell

- (void)awakeFromNib {
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    NSNumber* total = [[DashboardModel sharedInstance] totalNumberOfMolesMeasured];
    NSNumber* last = [[DashboardModel sharedInstance] numberOfMolesMeasuredSinceLastFollowup];
    float numb = 0.0f;
    if ([total floatValue] > 0.0) {numb = (float)[last floatValue] / (float)[total floatValue];};
    [self setDataToProgressView:numb];
    
    [self setupProgress];
    
    //_dbModel = [[DashboardModel alloc] init];
    
    //_ns_timer will fire the progress and text update
    _ns_timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    
    //_dbModel = [[DashboardModel alloc] init];
    _dateLbl.text = [self setDateLabelTextWithDate];
   
}

//logic if is today or not
- (NSString*) setDateLabelTextWithDate
{
    NSString *text = @"";
    NSNumber *daysUntilNextMonthlyFollowup = [[DashboardModel sharedInstance] daysUntilNextMeasurementPeriod];
    if ([daysUntilNextMonthlyFollowup intValue] == 0) {daysUntilNextMonthlyFollowup = @30;}
    if ([daysUntilNextMonthlyFollowup intValue] == 1)
    {
        text = [NSString stringWithFormat:@"%@ day until next monthly followup",daysUntilNextMonthlyFollowup];
    }
    else
    {
        text = [NSString stringWithFormat:@"%@ days until next monthly followup",daysUntilNextMonthlyFollowup];
    }
    
    /*
    if ([[DashboardModel sharedInstance] daysUntilNextMeasurementPeriod] == 0)
    {
        text = [NSString stringWithFormat:@"Today, %@", [self getFormatedDate]];
    }
    else
    {
        text = [NSString stringWithFormat:@"%@", [self getFormatedDate]];
    }
    */
    
    return text;
}

//date formatter to get the most accurate date in string
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

//setup the progress circles
-(void)setupProgress
{
    UIColor *c_gcolor = [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0];
    _grayCircle.tintColor = c_gcolor;
    _grayCircle.borderWidth = 10.0;
    _grayCircle.lineWidth = 10.0;
    [_grayCircle setProgress:1.0];
    
    UIColor *c_bcolor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    _progressView.tintColor = c_bcolor;
    _progressView.borderWidth = 10.0;
    _progressView.lineWidth = 10.0;
    [_progressView setProgress:0.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 60.0)];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
    label.text = @"0%";
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:21];
    label.textColor = _progressView.tintColor;
    _progressView.centralView = label;
  
    //we should check on the progressChangedBlock event to set string
    _progressView.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress) {
        [(UILabel*)_progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
    };
}

//asdasdasdasdasdasd such merge... very stuff here...
//update the progress bar on startup with updated string
- (void)updateProgress:(NSTimer *)timer
{
    if (_localProgress < _currentProgress - 0.01f)
    {
        _localProgress = ((int)((_localProgress * 100.0f) + 1.01) % 100) / 100.0f;
        [_progressView setProgress:_localProgress];
    }
    else
    {
        if (_currentProgress > 0.999999f)
        {
            [_progressView setProgress:1];
            [(UILabel*)_progressView.centralView setText:@"100%"];
        }
        else if (_currentProgress < 0.01f && _currentProgress > 0.00f)
        {
            [_progressView setProgress:0.01f];
            [(UILabel*)_progressView.centralView setText:@"1%"];
        }

        
        [_ns_timer invalidate];
    }
}

-(void)setDataToProgressView:(float) progress
{
    _currentProgress = progress;
}

//placeholder popup string, need to change when correct data is added
- (IBAction)showDescription:(UIButton *)sender {
    NSString *text = @"For each 30-day followup period, we ask that you re-measure the moles that you have measured previously to capture any changes over time.\n\nThis progress graph will re-set each time a followup period has elapsed. Thank you for contributing to our research!";
    [[PopupManager sharedInstance] createPopupWithText:text];
}

@end
