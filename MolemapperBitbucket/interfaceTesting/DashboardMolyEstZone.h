//
//  DashboardMolyEstZone.h
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Charts;

@interface DashboardMolyEstZone : UITableViewCell <ChartViewDelegate>
@property (strong, nonatomic) IBOutlet BarChartView *chartView;

@end
