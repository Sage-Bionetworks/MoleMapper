//
//  DashboardMolyEstZone.m
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardMolyEstZone.h"
#import "DashboardModel.h"

@implementation DashboardMolyEstZone

- (void)awakeFromNib {
    // Initialization code
    [self setDataToChart];
}

-(void) setDataToChart
{
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    
    _chartView.maxVisibleValueCount = 60;
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.spaceBetweenLabels = 2.0;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.drawGridLinesEnabled = NO;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    
    NSArray *zones = [[DashboardModel sharedInstance] zoneNameToNumberOfMolesInZoneDictionary];
    
    leftAxis.labelCount = [zones count];
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 1;
    leftAxis.valueFormatter.negativeSuffix = @"";
    leftAxis.valueFormatter.positiveSuffix = @"";
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.5;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.valueFormatter.maximumFractionDigits = 0;
    rightAxis.labelFont = [UIFont systemFontOfSize:0.f];
    rightAxis.labelCount = 0;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.5;
    
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    _chartView.legend.form = ChartLegendFormSquare;
    _chartView.legend.formSize = 9.0;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.xEntrySpace = 4.0;
    
    //NSArray *zones = [[DashboardModel sharedInstance] zoneNameToNumberOfMolesInZoneDictionary];
    
    NSInteger count = [zones count] > 5 ? 5 : [zones count];
    
    [self setDataCount:(int)count withRange:10];
}

- (void)setDataCount:(int)count withRange: (double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSArray *zones = [[DashboardModel sharedInstance] zoneNameToNumberOfMolesInZoneDictionary];

    for (int i = count - 1; i >= 0; i--)
    {
        NSDictionary *dict = zones[i];
        NSString* name = [dict objectForKey:@"name"];
        [xVals addObject:name];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        NSDictionary* dict = zones[i];
        NSNumber* value = [dict objectForKey:@"numberOfMolesInZone"];
        NSInteger zoneNumber = [value integerValue];
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:zoneNumber xIndex:(count - 1) - i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"Moles in Zones"];
    set1.barSpace = 0.35;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;
}

-(void) viewDidLoad
{
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
