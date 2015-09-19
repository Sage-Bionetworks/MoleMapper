//
//  DashboardModel.m
//  MoleMapper
//
//  Created by Andy Yeung on 9/12/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardModel.h"
#import "AppDelegate.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"

@implementation DashboardModel

-(instancetype)init{
    self = [super init];
    if (self) {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.context = ad.managedObjectContext;
    }
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t p = 0;
    
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

#pragma mark - Statistics from local data

-(NSNumber *)daysSinceLastFollowup
{
    NSDate *now = [NSDate date];
    NSDate *lastTimeAsurveyWasTaken;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    lastTimeAsurveyWasTaken = [ud valueForKey:@"dateOfLastSurveyCompleted"];
    
    NSNumber *daysSinceLastSurvey = [NSNumber numberWithInteger:[self daysBetweenDate:lastTimeAsurveyWasTaken andDate:now]];
    return daysSinceLastSurvey;
}

-(NSNumber *)numberOfZonesDocumented
{
    int numberOfZonesDocumented = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"zoneID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (Zone *zone in matches)
    {
        if ([self imageFileExistsForZone:zone]) {numberOfZonesDocumented++;}
    }
    NSNumber *numZones = [NSNumber numberWithInt:numberOfZonesDocumented];
    return numZones;
}

//Returns an array of all current mole measurements (as NSNumbers but are decimals)
-(NSArray *)allMoleMeasurements
{
    NSMutableArray *allMoleMeasurements = [NSMutableArray array];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    for (Measurement *measure in matches)
    {
        if ([measure.absoluteMoleDiameter doubleValue] > 0.0)
        {
            [allMoleMeasurements addObject:measure.absoluteMoleDiameter];
        }
    }
    return allMoleMeasurements;
}

//Returns the human-readable name for the biggest measured mole, or "No moles measured yet!" if no valid measurements
-(NSString *)nameForBiggestMole
{
    NSString *moleName = @"No moles measured yet!";
    Measurement *biggest = [self measurementForBiggestMole];
    if (biggest.measurementID != nil)
    {
        moleName = biggest.whichMole.moleName;
    }
    return moleName;
}

//Returns the human-readable name for the zone that contains the biggest measured mole, or "N/A" if no valid measurements
-(NSString *)zoneNameForBiggestMole
{
    NSString *zoneName = @"N/A";
    Measurement *biggest = [self measurementForBiggestMole];
    if (biggest.measurementID != nil)
    {
        NSNumber *zoneID = @([biggest.whichMole.whichZone.zoneID intValue]);
        zoneName = [Zone zoneNameForZoneID:zoneID];
    }
    return zoneName;
}

//Returns the absolute diameter (in mm) of the biggest mole, or nil if no measurements
-(NSNumber *)sizeOfBiggestMole
{
    Measurement *biggest = [self measurementForBiggestMole];
    NSNumber *diameter = biggest.absoluteMoleDiameter;
    return diameter;
}

//Returns the absolute diameter (in mm) of the average mole, or 0 if no measurements
-(NSNumber *)sizeOfAverageMole
{
    float totalMoleSizes = 0.0;
    int totalValidMeasurements = 0;
    NSNumber *averageMoleSize = @0;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.context];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&error];
    if (objects == nil) { } //Handle the error someday
    else
    {
        if ([objects count] > 0)
        {
            for (Measurement *meas in objects)
            {
                if ([meas.absoluteMoleDiameter doubleValue] > 0.0)
                {
                    totalMoleSizes += [meas.absoluteMoleDiameter floatValue];
                    totalValidMeasurements++;
                }
            }
            if (totalValidMeasurements > 0)
            {
                averageMoleSize = [NSNumber numberWithFloat:(totalMoleSizes / totalValidMeasurements)];
            }
        }
    }
    return averageMoleSize;
}

//Returns a mapping of human-readable zone name (like left shoulder) to number of moles within that zone
-(NSDictionary *)zoneNameToNumberOfMolesInZoneDictionary
{
    NSMutableDictionary *zonesToMoles = [NSMutableDictionary dictionary];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    for (Zone *zone in matches)
    {
        NSSet *moles = zone.moles;
        int moleNum = (int)[moles count];
        NSNumber *numberOfMoles = [NSNumber numberWithInt:moleNum];
        NSNumber *zoneID = @([zone.zoneID intValue]);
        NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
        [zonesToMoles setValue:numberOfMoles forKey:zoneName];
    }
    return zonesToMoles;
}

/*
 - (NSMutableDictionary*)rankedListOfMoleSizeChangeAndMetadata {}
 - Return in order of highest upward variance //no need that from now on
 - Returns: [{"name": @"", "Size": NSNumber*, "percentChange": NSNumber*, "measurement": Measurement*}, ...]
 */
-(NSMutableDictionary*) rankedListOfMoleSizeChangeAndMetadata
{
    NSMutableDictionary *listOfMoles = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < 10; ++i)
    {
        NSString *key = [NSString stringWithFormat:@"%i",i];
        
        NSMutableDictionary *moleDict = [NSMutableDictionary dictionary];
        [moleDict setObject:@"holymoly" forKey:@"name"];
        [moleDict setObject:[NSNumber numberWithFloat:i] forKey:@"size"];
        [moleDict setObject:[NSNumber numberWithFloat:i] forKey:@"percentChange"];
        [moleDict setObject:[NSNumber numberWithFloat:i] forKey:@"measurement"];
        
        [listOfMoles setObject:moleDict forKey: key];
    }
    
    return listOfMoles;
}


//If user has provided their zip code during initial onboarding, this will
//return their zip code as a string

//DEBUG test... 
/*-(NSString *)zipCodeForUser
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return ad.bridgeManager.bridgeProfileZipCode;
}*/

#pragma mark - Helper methods

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

//Helper method to check if file exists for a given zone, indicating it has been documented
-(BOOL)imageFileExistsForZone:(Zone *)zone
{
    BOOL fileExists;
    NSString *zoneID = [NSString stringWithFormat:@"zone%@",zone.zoneID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filename = [zoneID stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return fileExists;
}

//Returns the measurement object for biggest mole, where you can get other data from it
-(Measurement *)measurementForBiggestMole
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"absoluteMoleDiameter" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    
    Measurement *measurementForBiggestMole = [matches lastObject];
    return measurementForBiggestMole;
}


@end
