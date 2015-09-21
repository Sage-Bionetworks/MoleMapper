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
    
    /*self.title = @"Bar Chart";
     
     self.options = @[
     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
     @{@"key": @"toggleHighlightArrow", @"label": @"Toggle Highlight Arrow"},
     @{@"key": @"animateX", @"label": @"Animate X"},
     @{@"key": @"animateY", @"label": @"Animate Y"},
     @{@"key": @"animateXY", @"label": @"Animate XY"},
     @{@"key": @"toggleStartZero", @"label": @"Toggle StartZero"},
     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
     ];*/
    
    //_chartView.delegate = self;
    
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
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 1;
    leftAxis.valueFormatter.negativeSuffix = @"";
    leftAxis.valueFormatter.positiveSuffix = @"";
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    
    _chartView.legend.position = ChartLegendPositionBelowChartLeft;
    _chartView.legend.form = ChartLegendFormSquare;
    _chartView.legend.formSize = 9.0;
    _chartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _chartView.legend.xEntrySpace = 4.0;
    
    [self setDataCount:5];
}

- (void)setDataCount:(int)count
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSArray *zones = [[DashboardModel sharedInstance] zoneNameToNumberOfMolesInZoneDictionary];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:zones[i % [zones count]]];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        NSInteger zoneNumber = [[zones objectAtIndex:0] objectForKey:@"numberOfMolesInZone"];
        NSInteger mult = (zoneNumber + 1);
        //NSInteger val = (double) (arc4random_uniform(mult));
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:(double)mult xIndex:i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"DataSet"];
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
