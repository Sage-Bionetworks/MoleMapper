//
//  DashboardUVExposure.h
//  MoleMapper
//
//  Created by Karpács István on 21/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
//@import CoreLocation;

@import Charts;

@interface DashboardUVExposure : UITableViewCell <ChartViewDelegate, CLLocationManagerDelegate>
{
@private
    MKMapView *_mapView;
    CLLocationManager *_locationManager;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *headerTitle;
//@property(nonatomic, strong) CLLocationManager *locationManager;
- (IBAction)popupPressed:(UIButton *)sender;
@property __block NSArray* jsonUVIndexDictionary;
@end
