//
//  DashboardZoneDocumentationCell.h
//  MoleMapper
//
//  Created by Karpács István on 15/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
#import "DashboardModel.h"

@interface DashboardZoneDocumentationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UAProgressView *grayCircle;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *documentedZones;
//@property (weak, nonatomic) IBOutlet UILabel *participantsZones;
//@property (retain, nonatomic) IBOutlet UIView *bodyFronView;
//@property (retain, nonatomic) IBOutlet UIView *bodyBackView;

@property (nonatomic, assign) CGFloat localProgress;
@property (nonatomic, assign) CGFloat currentProgress;
@property (nonatomic, assign) NSTimer* ns_timer;
@property (nonatomic, assign) UIViewController* parentViewController;

//@property DashboardModel* dbModel;
@property BOOL isTimerInvalidated;

-(void)setDataToProgressView:(CGFloat) progress;

@end
