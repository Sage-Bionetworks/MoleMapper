//
//  DashboardUVExposure.h
//  MoleMapper
//
//  Created by Karpács István on 21/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;

@interface DashboardUVExposure : UITableViewCell <ChartViewDelegate>
@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
- (IBAction)popupPressed:(UIButton *)sender;
@property __block NSArray* jsonUVIndexDictionary;
@end
