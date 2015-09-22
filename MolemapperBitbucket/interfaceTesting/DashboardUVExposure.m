//
//  DashboardUVExposure.m
//  MoleMapper
//
//  Created by Karpács István on 21/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardUVExposure.h"
#import "DashboardModel.h"

@implementation DashboardUVExposure


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self getUVJsonDataByZipCode];
    // Configure the view for the selected state
}

-(void) getUVJsonDataByZipCode
{
    // Prepare the link that is going to be used on the GET request
    NSURL * url = [[NSURL alloc] initWithString:@"http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/20902/JSON"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    //__block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               _jsonUVIndexDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:0
                                                                                          error:nil];
                               [self setupChartView];
                               NSLog(@"Async JSON: %@", _jsonUVIndexDictionary);
                           }];
}

-(void)setupChartView
{
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    //[leftAxis addLimitLine:ll1];
    //[leftAxis addLimitLine:ll2];
    leftAxis.customAxisMax = [self getHighestUVValueFromJson];
    leftAxis.customAxisMin = 0;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    
    _chartView.rightAxis.enabled = NO;

    [self setDataCount:(int)[_jsonUVIndexDictionary count] range:[self getHighestUVValueFromJson]];
    [_chartView animateWithXAxisDuration:0.0 yAxisDuration:3.0];
}

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_jsonUVIndexDictionary count]; i++)
    {
        //double mult = (range + 1);
        int val = [self getUVBasedIndex:i];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"DataSet 1"];
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.blackColor];
    [set1 setCircleColor:[[DashboardModel sharedInstance] getColorForDashboardTextAndButtons]];
    set1.lineWidth = 1.0;
    set1.circleRadius = 3.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.fillAlpha = 65/255.0;
    set1.fillColor = UIColor.blackColor;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    _chartView.data = data;
    
    
}

-(int) getUVBasedIndex: (int) idx
{
    NSDictionary* currentUvData = [_jsonUVIndexDictionary objectAtIndex:idx];
    NSNumber* currectUv = [currentUvData objectForKey:@"UV_VALUE"];
    return (int)[currectUv integerValue];
}

-(int) getHighestUVValueFromJson
{
    int highestUV = 0;
    for (int i = 0; i < (int)[_jsonUVIndexDictionary count]; ++i)
    {
        int currentUv = [self getUVBasedIndex: i];
        highestUV = currentUv > highestUV ? currentUv : highestUV;
    }
    
    return highestUV + 1;
}



@end
