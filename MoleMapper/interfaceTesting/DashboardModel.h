//
//  DashboardModel.h
//  MoleMapper
//
//  Created by Andy Yeung on 9/12/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Measurement.h"

@interface DashboardModel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

//local cache of the most recent UV data while fetching from EPA on refresh
@property (strong, nonatomic) NSData *mostRecentStoredUVdata;

+ (id)sharedInstance;
-(NSNumber *)daysUntilNextMeasurementPeriod;
-(NSArray *)zoneNameToNumberOfMolesInZoneDictionary;
-(NSNumber *)numberOfZonesDocumented;
-(NSArray *)allMoleMeasurements;
-(NSString *)nameForBiggestMole;
-(NSString *)zoneNameForBiggestMole;
-(NSNumber *)sizeOfBiggestMole;
-(NSNumber *)sizeOfAverageMole;
-(NSMutableDictionary*) rankedListOfMoleSizeChangeAndMetadata;
-(NSNumber *)totalNumberOfMolesMeasured;
-(NSNumber *)numberOfMolesMeasuredSinceLastFollowup;
-(NSInteger) getAllZoneNumber;
-(Measurement *)measurementForBiggestMole;
-(void) refreshContext;

-(float) correctFloat:(float) value;
-(UIColor*) getColorForDashboardTextAndButtons;
-(UIColor*) getColorForHeader;

@end
