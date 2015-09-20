//
//  DashboardActivityCompletionCell.m
//  UCSF Pride
//
//  Created by Christian Curiel on 5/17/15.
//  Edited by István Karpács
//  Copyright (c) 2015 Analog Republic. All rights reserved.
//

#import "DashboardActivityCompletionCell.h"
#import "PopupManager.h"

@implementation DashboardActivityCompletionCell

- (void)awakeFromNib {
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
    NSString* text = @"";
    
    if ([[DashboardModel sharedInstance] daysUntilNextMeasurementPeriod]/*[_dbModel daysSinceLastFollowup]*/ == 0)
    {
        text = [NSString stringWithFormat:@"Today, %@", [self getFormatedDate]];
    }
    else
    {
        text = [NSString stringWithFormat:@"%@", [self getFormatedDate]];
    }
    
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
    
    UIColor *c_bcolor = [UIColor colorWithRed:0 / 255.0 green:171.0 / 255.0 blue:235.0 / 255.0 alpha:1.0];
    _progressView.tintColor = c_bcolor;
    _progressView.borderWidth = 10.0;
    _progressView.lineWidth = 10.0;
    [_progressView setProgress:0.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 60.0)];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
    label.text = @"0%%";
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
    if (_localProgress < _currentProgress - 0.01)
    {
        _localProgress = ((int)((_localProgress * 100.0f) + 1.01) % 100) / 100.0f;
        [_progressView setProgress:_localProgress];
    }
    else
    {
        [_ns_timer invalidate];
    }
}

-(void)setDataToProgressView:(CGFloat) progress
{
    _currentProgress = progress;
}

//placeholder popup string, need to change when correct data is added
- (IBAction)showDescription:(UIButton *)sender {
    NSString *text = @"Your Dashboard is a collection of graphs and data based on completed app Activities. View and complete tasks in the Activities tab to see your completion rate.";
    [[PopupManager sharedInstance] createPopupWithText:text];
}

@end
