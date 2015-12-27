//
//  DashboardZoneDocumentationCell.m
//  MoleMapper
//
//  Created by Karpács István on 15/09/15.
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


#import "DashboardZoneDocumentationCell.h"
#import "BodyMapViewController.h"
#import "BodyFrontView.h"
#import "BodyBackView.h"
#import "VariableStore.h"
#import "AppDelegate.h"

@interface DashboardZoneDocumentationCell ()
{
    VariableStore *vars;
}
@property (strong, nonatomic) BodyFrontView *bodyFront;
@property (strong, nonatomic) BodyBackView *bodyBack;
@end

@implementation DashboardZoneDocumentationCell

- (void)awakeFromNib {
    // Initialization code
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    [self setupProgress];
    _isTimerInvalidated = YES;
    [self initZonesDocumented];
}

- (void) initZonesDocumented
{
    NSNumber* zonesDoced = [[DashboardModel sharedInstance] numberOfZonesDocumented];
    
    _documentedZones.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    _documentedZones.text = [NSString stringWithFormat:@"%i Zones", (int)[zonesDoced integerValue]];
    
    _currentProgress = 0.0;
    _localProgress = 0.0;
    [_progressView setProgress:_currentProgress animated:YES];
    
    if (_isTimerInvalidated)
    {
        _isTimerInvalidated = NO;
        _ns_timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        
        //need to set all of the bodyparts and also those which is already covered
        float bodyparts = (float)[[DashboardModel sharedInstance] getAllZoneNumber];
        float bodypartsCovered = [[DashboardModel sharedInstance] correctFloat:[zonesDoced floatValue]];
        //float bodypartsCovered = 30.0f;
        float percent = bodyparts > 0.0 ? (float)bodypartsCovered / (float)bodyparts : 0.0;
        
        [self setDataToProgressView:percent];
    }
}

-(void)setupProgress
{
    //setup graycolor for progressbar
    UIColor *c_gcolor = [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0];
    _grayCircle.tintColor = c_gcolor;
    _grayCircle.borderWidth = 10.0;
    _grayCircle.lineWidth = 10.0;
    [_grayCircle setProgress:1.0];
    
    UIColor *c_bcolor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    _progressView.tintColor = c_bcolor;
    _progressView.borderWidth = 10.0;
    _progressView.lineWidth = 10.0;
    [_progressView setProgress:_currentProgress animated:YES];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60.0, 60.0)];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.userInteractionEnabled = NO; // Allows tap to pass through to the progress view.
    label.text = @"0%%";
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:21];
    label.textColor = _progressView.tintColor;
    _progressView.centralView = label;
    
    _progressView.progressChangedBlock = ^(UAProgressView *progressView, CGFloat progress)
    {
        if (progress == 100)
        {
            [(UILabel*)_progressView.centralView setText:[NSString stringWithFormat:@"%3.0f%%", progress * 100]];
        }
        else
        {
            [(UILabel*)_progressView.centralView setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
        }
    };
}

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
        else if (_currentProgress < 0.01f && _currentProgress > 0)
        {
            [_progressView setProgress:0.01f];
            [(UILabel*)_progressView.centralView setText:@"1%"];
        }
        _isTimerInvalidated = YES;
        [_ns_timer invalidate];
    }
}

- (void)setupParentViewController: (UIViewController*) vc
{
    _parentViewController = vc;
}

- (void)setDataToProgressView:(float) progress
{
    _currentProgress = progress;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //[self initZonesDocumented];

    
    //need to set all of the bodyparts and also those which is already covered
    /*float bodyparts = totalNumberOfZones;
    float bodypartsCovered = 37;
    
    float percent = bodypartsCovered / bodyparts;
    
    [self setDataToProgressView:percent];*/
    
    //_localProgress = 0.0;
    //_ns_timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
    // Configure the view for the selected state
}

@end