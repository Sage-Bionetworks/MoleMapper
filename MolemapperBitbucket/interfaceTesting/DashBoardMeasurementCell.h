//
//  DashBoardMeasurementCell.h
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardModel.h"
#import "DashboardViewController.h"

@interface DashBoardMeasurementCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIButton *viewMoleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *lineOfMeasurement;
@property (weak, nonatomic) IBOutlet UILabel *biggestMoleLabel;
@property (weak, nonatomic) IBOutlet UILabel *locatedMoleLabel;

- (IBAction)presentMoleViewController:(UIButton *)sender;

@property DashboardViewController* dashBoardViewController;
@property NSMutableArray *dotSubviews;

//@property DashboardModel* dbModel;

@end
