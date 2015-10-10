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
#import "AFNetworkReachabilityManager.h"

@implementation DashboardUVExposure

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define dataRate 9

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
    
    _chartView.delegate = self;
    
    NSData *data = [[DashboardModel sharedInstance] mostRecentStoredUVdata];
    
    if (data != nil)
    {
        _jsonUVIndexDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //[self setupChartView];
    }
    //DEBUG
    
    [self getUVJsonDataWithZipCode:@""];
    [self setDescriptionLabels];
    ///////
    [self setupLocationService];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [_locationManager stopUpdatingLocation];
    
    //NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    //NSLog(@"%@",theLocation);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        
        CLPlacemark *placemark = [placemarks lastObject];
        NSLog(@"%@", placemark.postalCode);
        
        [self setDescriptionLabels];
        [self getUVJsonDataWithZipCode:placemark.postalCode];
        
    }];
}

-(void)setupLocationService
{
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //[_locationManager startUpdatingLocation];
    
    if (self.locationManager==nil) {
        self.locationManager = [[CLLocationManager alloc]init];
    }
    self.locationManager.delegate = self;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted){  }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            [self.locationManager requestWhenInUseAuthorization];
            //[self getUVJsonDataByZipCode];
        }
    }
    
    if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        //[self getUVJsonDataByZipCode];
    }
    
    [self.locationManager startUpdatingLocation];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Is this my Alert View?
    if (alertView.tag == 1001)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

-(void) getUVJsonDataWithZipCode: (NSString*) zipCode
{
    @try
    {
        NSString* urlString = [NSString stringWithFormat:@"http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/%@/JSON", zipCode];
        NSURL * url = [[NSURL alloc] initWithString:urlString];
        //
        //NSURL * url = [[NSURL alloc] initWithString:@"http://iaspub.epa.gov/enviro/efservice/getEnvirofactsUVHOURLY/ZIP/20902/JSON"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                                    completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
        {
            if (data != nil)
            {
                [[DashboardModel sharedInstance] setMostRecentStoredUVdata:data];
                NSArray* tempData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (tempData != _jsonUVIndexDictionary)
                {
                    _jsonUVIndexDictionary = tempData;
                    //NSLog(@"Async JSON: %@", _jsonUVIndexDictionary);
                    [self setupChartView];
                }
            }
        }];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        NSString *titles;
        titles = @"Bad region";
        NSString *msg = @"Service is not available on your region.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titles
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)setupChartView
{
    _chartView.descriptionText = @"";
    //_chartView.noDataTextDescription = @"Please provide location permission to see UV Index information in your area";
    
    _chartView.dragEnabled = NO;
    [_chartView setScaleEnabled:NO];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = YES;
    _chartView.gridBackgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = [self getHighestUVValueFromJson];
    leftAxis.labelCount = [self getHighestUVValueFromJson];
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
    rightAxis.labelCount = [self getHighestUVValueFromJson];
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
    
    if ([_jsonUVIndexDictionary count] > 0)
        [self setDataCount];
    [_chartView animateWithXAxisDuration:0.0 yAxisDuration:1.0];
}

- (void)setDataCount
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    //int startPos = [self chartStartPos];
    
    //add 2 to get it in the middle
    int startPos = [self getStartOrderPostion];
    
    for (int i = startPos; i < startPos + dataRate; i++)
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
    
    for (int i = 0; i < dataRate; i++)
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

-(void) setDescriptionLabels
{
    int highestUV = 0;
    for (int i = 0; i < (int)[_jsonUVIndexDictionary count]; ++i)
    {
        int currentUv = [self getUVBasedIndex: i];
        highestUV = currentUv > highestUV ? currentUv : highestUV;
    }
    
    _highestUVLabel.text = [NSString stringWithFormat:@"%i", highestUV];
    _timeLabel.text = [NSString stringWithFormat:@"%@", [self getCurrentTimeString]];
    
}

-(NSString*) getCurrentTimeString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    NSInteger currentHour = [components hour];

    NSString* timeString = @"";
    BOOL moreThenTwelve = NO;
    
    if (currentHour > 12)
    {
        moreThenTwelve = YES;
        timeString = [NSString stringWithFormat:@"%i PM", (int)currentHour - 12];
    }
    else if (currentHour == 24)
    {
        moreThenTwelve = YES;
        timeString = [NSString stringWithFormat:@"%i AM", (int)currentHour - 12];
    }
    else if (currentHour < 12)
        timeString = [NSString stringWithFormat:@"%i AM", (int)currentHour];
    else if (currentHour == 12)
        timeString = [NSString stringWithFormat:@"%i PM", (int)currentHour];
    
    if (currentHour < 7 && currentHour > 3)
    {
        return [NSString stringWithFormat:@"%@ | -", timeString];
    }
    
    if (moreThenTwelve)
        currentHour -=  12;

    for (int i = 0; i < [_jsonUVIndexDictionary count]; ++i)
    {
        //need to put here for testing... need to change the calling methods tho...
        NSDictionary* currentUvData = [_jsonUVIndexDictionary objectAtIndex:i];
        NSString* dateTime = [currentUvData objectForKey:@"DATE_TIME"];
        NSArray* dateTimeArray = [dateTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        NSString* hourString = [dateTimeArray objectAtIndex:1];
        NSString* firstChar = [hourString substringToIndex:1];
        NSString* correctHourString = [firstChar isEqualToString:@"0"] ? [hourString componentsSeparatedByString:@"0"][1] : hourString;
        int hourInt = [[correctHourString stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
        
        NSString *currentTimeBase = [dateTimeArray objectAtIndex:2];
        BOOL isTimeBaseCorrect = [timeString containsString:currentTimeBase];
        
        if (hourInt == currentHour && isTimeBaseCorrect)
        {
            return [NSString stringWithFormat:@"%@ | %i", timeString, [self getUVBasedIndex:i]];
            break;
        }
    }
    
    return @"";
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
    
    if (highestUV % 2 > 0)
        highestUV += 2;
    else highestUV++;
    
    return highestUV;
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
        if (hourInt == 12 || hourInt == 0)
            return [self getFirstOrderPosition:(int)currentHour: 12 withDictionary:currentUvData];
        
        if (hourInt == (int)currentHour)
            return [self getFirstOrderPosition:(int)currentHour: hourInt withDictionary:currentUvData];
    }
    
    if ([[dateTimeArray objectAtIndex:2] isEqualToString:@"PM"])
    {
        if (hourInt == (int)currentHour - 12)
            return [self getFirstOrderPosition:(int)currentHour - 12: hourInt withDictionary:currentUvData];
        
        if (hourInt == 12 && currentHour == 12)
            return [self getFirstOrderPosition:12: hourInt withDictionary:currentUvData];
    }
    
    return -1;
}

- (int) getFirstOrderPosition: (int) currentHour : (int) hourInt withDictionary: (NSDictionary*) currentUvData
{
    //int _dataRate = 9;
    
    int order = (int)[(NSNumber*)[currentUvData objectForKey:@"ORDER"] integerValue];
    
    if (order - dataRate / 2 >= 1 && order + dataRate / 2 < [_jsonUVIndexDictionary count])
    {
        return order - dataRate / 2;
    }
    else if (order - dataRate / 2 < 1)
    {
        return 0;
    }
    else if (order + dataRate / 2 >= [_jsonUVIndexDictionary count])
    {
        return (int)[_jsonUVIndexDictionary count] - dataRate;
    }
    
    return nil;
}

- (IBAction)popupPressed:(UIButton *)sender {
    NSString *text = @"This localized UV Index forecast operates on a scale of 0 (least risk) to 11 (most risk). UV indices for evening hours may be unavailable.\n\nThis information is provided by the US Environmental Protection Agency (EPA). For more information, please visit their website.";
    
    [[PopupManager sharedInstance] createPopupWithText:text];
}


#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    //NSString *selectedTime = (NSString*)[_chartView.data.xValsObjc objectAtIndex:entry.xIndex];
    //int selectedValue = entry.value;
    
    //_selectedUVLabel.text = [NSString stringWithFormat:@"%@ | %i", selectedTime, selectedValue];
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    //_selectedUVLabel.text = [NSString stringWithFormat:@"- | -"];
}

@end
