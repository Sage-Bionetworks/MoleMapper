//
//  DashboardActivityCompletionCell.h
//  UCSF Pride
//
//  Created by Christian Curiel on 5/17/15.
//  Copyright (c) 2015 Analog Republic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAProgressView.h"
#import "DashboardModel.h"

@interface DashboardActivityCompletionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UAProgressView *progressView;
@property (weak, nonatomic) IBOutlet UAProgressView *grayCircle;
@property (weak, nonatomic) IBOutlet UIButton *questionButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;

@property (nonatomic, assign) float localProgress;
@property (nonatomic, assign) float currentProgress;
@property (nonatomic, assign) NSTimer* ns_timer;

//@property DashboardModel *dbModel;

-(void)setDataToProgressView:(float) progress;
- (IBAction)showDescription:(UIButton *)sender;

@end
