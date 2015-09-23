//
//  DashboardUVExposure.m
//  MoleMapper
//
//  Created by Karpács István on 21/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardUVExposure.h"
#import "DashboardModel.h"
#import "PopupManager.h"
@import CoreLocation;

@implementation DashboardUVExposure


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
    [self getUVJsonDataByZipCode];
    
    /*if([CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Permission Denied"
                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Permission Denied"
                                                            message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }*/
}

-(void) getUVJsonDataByZipCode
{
    // Prepare the link that is going to be used on the GET request
    NSURL * url = [[NSURL alloc] initWithString:@"http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/20902/JSON"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

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

    
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"Please provide location permission to see UV Index information in your area";
    
    _chartView.dragEnabled = NO;
    [_chartView setScaleEnabled:NO];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = YES;
    _chartView.gridBackgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = [self getHighestUVValueFromJson];
    leftAxis.customAxisMin = 0;
    leftAxis.startAtZeroEnabled = NO;
    leftAxis.gridLineDashLengths = @[@1.f, @1.f];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    leftAxis.gridColor = [UIColor clearColor];
    leftAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    leftAxis.valueFormatter.maximumFractionDigits = 0;
    leftAxis.xOffset = 9.0;
    
    ChartYAxis *rightAxis = _chartView.rightAxis;
    [rightAxis removeAllLimitLines];
    rightAxis.customAxisMax = [self getHighestUVValueFromJson];
    rightAxis.customAxisMin = 0;
    rightAxis.startAtZeroEnabled = NO;
    rightAxis.gridLineDashLengths = @[@1.f, @1.f];
    rightAxis.drawLimitLinesBehindDataEnabled = YES;
    rightAxis.gridColor = [UIColor clearColor];
    rightAxis.valueFormatter = [[NSNumberFormatter alloc] init];
    rightAxis.valueFormatter.maximumFractionDigits = 0;
    rightAxis.xOffset = 9.0;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:9.f];
    xAxis.drawGridLinesEnabled = YES;
    xAxis.spaceBetweenLabels = 1.0;
    
    _chartView.rightAxis.enabled = YES;

    [self setDataCount];
    [_chartView animateWithXAxisDuration:0.0 yAxisDuration:1.0];
}

- (void)setDataCount
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    //int startPos = [self chartStartPos];
    
    int startPos = [self getStartOrderPostion];
    
    for (int i = startPos; i < startPos + 7; i++)
    {
        NSString* dateTime = [[_jsonUVIndexDictionary objectAtIndex:i] objectForKey:@"DATE_TIME"];
        NSArray* dateTimeArray = [dateTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSString* hourString = [dateTimeArray objectAtIndex:1];
        NSString* firstChar = [hourString substringToIndex:1];
        NSString* correctHourString = [firstChar isEqualToString:@"0"] ? [hourString componentsSeparatedByString:@"0"][1] : hourString;
        NSString* xDataLabel = [NSString stringWithFormat:@"%@ %@", correctHourString, [dateTimeArray objectAtIndex:2]];
        [xVals addObject:xDataLabel];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 8; i++)
    {
        int val = (int)[self getUVBasedIndex:i + startPos];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@""];
    
    set1.lineDashLengths = @[@1.f, @1.0f];
    [set1 setColor:UIColor.whiteColor];
    [set1 setCircleColor:[[DashboardModel sharedInstance] getColorForDashboardTextAndButtons]];
    set1.lineWidth = 0.0;
    set1.circleRadius = 6.0;
    set1.drawCircleHoleEnabled = YES;
    set1.valueFont = [UIFont systemFontOfSize:0.f];
    set1.fillAlpha = 255/255.0;
    set1.fillColor = UIColor.clearColor;
    
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

-(int) getStartOrderPostion
{
    for (int i = 0; i < (int)[_jsonUVIndexDictionary count]; ++i)
    {
        int x = [self orderPosition:i];
        if (x != -1) return x;
    }
    
    return nil;
}

-(int) orderPosition : (int) idx
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger currentHour = [components hour];
    
    NSDictionary* currentUvData = [_jsonUVIndexDictionary objectAtIndex:idx];
    NSString* dateTime = [currentUvData objectForKey:@"DATE_TIME"];
    NSArray* dateTimeArray = [dateTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    NSString* hourString = [dateTimeArray objectAtIndex:1];
    NSString* firstChar = [hourString substringToIndex:1];
    NSString* correctHourString = [firstChar isEqualToString:@"0"] ? [hourString componentsSeparatedByString:@"0"][1] : hourString;
    int hourInt = [[correctHourString stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
    
    if ([[dateTimeArray objectAtIndex:2] isEqualToString:@"AM"])
    {
        if (hourInt == (int)currentHour)
            return [self getFirstOrderPosition:(int)currentHour: hourInt withDictionary:currentUvData];
    }
    
    if ([[dateTimeArray objectAtIndex:2] isEqualToString:@"PM"])
    {
        if (hourInt == (int)currentHour - 12)
            return [self getFirstOrderPosition:(int)currentHour - 12: hourInt withDictionary:currentUvData];
    }
    
    return -1;
}

- (int) getFirstOrderPosition: (int) currentHour : (int) hourInt withDictionary: (NSDictionary*) currentUvData
{
    int dataRate = 7;
    
    int order = (int)[(NSNumber*)[currentUvData objectForKey:@"ORDER"] integerValue];
    
    if (order - dataRate >= 1 && order + dataRate < [_jsonUVIndexDictionary count])
    {
        return (order - dataRate) - 1;
    }
    else if (order - dataRate < 1)
    {
        return 0;
    }
    else if (order + dataRate >= [_jsonUVIndexDictionary count])
    {
        return ((int)[_jsonUVIndexDictionary count] - dataRate) - 1;
    }
    
    return nil;
}

- (IBAction)popupPressed:(UIButton *)sender {
    NSString *text = @"This UV Index forecast, provided by the US Environmental Protection Agency, operates on a scale of 0 (least risk) to 11 (most risk). The UV Index measurement here is based on your current zip code. To enable this information, please provide permissions for Location Services in Settings.";
    [[PopupManager sharedInstance] createPopupWithText:text];
}


@end
