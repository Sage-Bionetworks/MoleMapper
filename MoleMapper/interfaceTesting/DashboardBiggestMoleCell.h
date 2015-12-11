//
//  DashboardBiggestMoleCell.h
//  MoleMapper
//
//  Created by Karpács István on 16/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardModel.h"

@interface DashboardBiggestMoleCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
@property (weak, nonatomic) IBOutlet UIImageView *innerCircle;
@property (weak, nonatomic) IBOutlet UIImageView *outerCircle;
@property (weak, nonatomic) IBOutlet UILabel *outerCircleLabel;
@property (weak, nonatomic) IBOutlet UILabel *innerCircleLabel;

//@property DashboardModel *dbModel;

@end
