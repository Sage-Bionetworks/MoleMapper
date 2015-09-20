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
#import "Math.h"

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

-(NSNumber *)totalNumberOfMolesMeasured
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *allMoles = [self.context executeFetchRequest:request error:&error];
    
    int totalNumberOfMeasuredMoles = 0;
    
    for (Mole *mole in allMoles)
    {
        NSSet *measurementsForMole = mole.measurements;
        if (measurementsForMole.count == 0)
        {
            continue; //If no measurements for a given mole, has never been measured
        }
        else if (measurementsForMole.count > 1) //Has at least one measurement
        {
            totalNumberOfMeasuredMoles++;
        }
        else
        {
            NSLog(@"Strange situaiton in which you have a negative return value for fetching measurements for a mole.");
        }
    }
    return [NSNumber numberWithInt:totalNumberOfMeasuredMoles];
}

/*
 Get the current date, Get the date since last survey, the date of most recent measurement for all moles
 If more than the number of days in a followup period has elapsed, this number will be zero. Otherwise
 checks to see if measurement date falls within the time period of now and last time a survey was taken
 */
-(NSNumber *)numberOfMolesMeasuredSinceLastFollowup
{
    
    int numberOfMolesMeasuredSinceLastFollowup = 0;
    NSDate *now = [NSDate date];
    NSDate *lastTimeAsurveyWasTaken;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    lastTimeAsurveyWasTaken = [ud valueForKey:@"dateOfLastSurveyCompleted"];
    
    NSInteger numberOfDaysBetweenNowAndLastFollowup = [self daysBetweenDate:now andDate:lastTimeAsurveyWasTaken];
    if (numberOfDaysBetweenNowAndLastFollowup > numberOfDaysInFollowupPeriod)
    {
        //Since the followup period changes every 30 days, if that amount of time has elapsed, reset
        numberOfMolesMeasuredSinceLastFollowup = 0;
    }
    else
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
        
        NSError *error = nil;
        NSArray *allMoles = [self.context executeFetchRequest:request error:&error];
        
        int totalNumberOfMeasuredMoles = 0;
        
        for (Mole *mole in allMoles)
        {
            Measurement *mostRecent = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
            if (mostRecent)
            {
                NSDate *dateOfMeasurement = mostRecent.date;
                if ([self date:dateOfMeasurement isBetweenDate:lastTimeAsurveyWasTaken andDate:now])
                {
                    totalNumberOfMeasuredMoles++;
                }
            }
        }
    }
    
    return [NSNumber numberWithInt:numberOfMolesMeasuredSinceLastFollowup];
}

-(NSNumber *)daysUntilNextMeasurementPeriod
{
    NSDate *now = [NSDate date];
    NSDate *lastTimeAsurveyWasTaken;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    lastTimeAsurveyWasTaken = [ud valueForKey:@"dateOfLastSurveyCompleted"];
    
    NSInteger daysSinceLastSurvey = [self daysBetweenDate:lastTimeAsurveyWasTaken andDate:now];
    NSInteger daysUntilNextMeasurementPeriod = daysSinceLastSurvey % numberOfDaysInFollowupPeriod;
    NSNumber *returnValue = [NSNumber numberWithInteger:daysUntilNextMeasurementPeriod];
    return returnValue;
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

//Returns a sorted array (highest to lowest number of moles in Zone) of human-readable zone name (like left shoulder) to number of moles within that zone
// [{"name": zoneName, "count": numberOfMolesInZone(NSNumber)}, ...]
-(NSDictionary *)zoneNameToNumberOfMolesInZoneDictionary
{
    NSMutableDictionary *zonesToMoles = [NSMutableDictionary dictionary];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    //NSArray *arrayOfDictionaries
    for (Zone *zone in matches)
    {
        NSSet *moles = zone.moles;
        int moleNum = (int)[moles count];
        NSNumber *numberOfMoles = [NSNumber numberWithInt:moleNum];
        NSNumber *zoneID = @([zone.zoneID intValue]);
        NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
        [zonesToMoles setValue:zoneName forKey:@"name"];
        [zonesToMoles setValue:numberOfMoles forKey:@"numberOfMolesInZone"];
    }
    
    
    NSSortDescriptor *sortByMoles = [[NSSortDescriptor alloc] initWithKey:@"numberOfMolesInZone" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByMoles];
    //return [zonesToMoles sortedArrayUsingDescriptors:sortDescriptors];

}

/*
 - (NSMutableDictionary*)rankedListOfMoleSizeChangeAndMetadata {}
 - Return in order of highest upward variance //no need that from now on
 - Returns: [{"name": @"", "size": NSNumber*, "percentChange": NSNumber*, "measurement": Measurement*}, ...]
 */

-(NSMutableDictionary*) rankedListOfMoleSizeChangeAndMetadata
{
    NSArray *sortedMoles = [self measurementsInOrderOfMostIncreasedPercentage];
    
    NSMutableDictionary *listOfMoles = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < sortedMoles.count; ++i)
    {
        NSString *key = [NSString stringWithFormat:@"%i",i];
        NSMutableDictionary *moleDict = sortedMoles[i];
        [listOfMoles setObject:moleDict forKey: key];
    }
    
    //USE FOR DEBUG ON SIMULATOR
    /*for (int i = 0; i < 10; ++i)
    {
        
        //NSDate *date = [NSDate date];
        
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:27];
        [comps setMonth:2];
        [comps setYear:1987];
        NSDate* correctedDay = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        NSString *key = [NSString stringWithFormat:@"%i",i];
        NSMutableDictionary *moleDict = [NSMutableDictionary dictionary];
        [moleDict setObject:@"holymoly" forKey:@"name"];
        [moleDict setObject:[NSNumber numberWithFloat:i] forKey:@"size"];
        [moleDict setObject:[NSNumber numberWithFloat:i] forKey:@"percentChange"];
        [moleDict setObject:[NSDate date] forKey:@"measurement"];
        [listOfMoles setObject:moleDict forKey: key];
    }*/

    return listOfMoles;
}

-(NSArray *)measurementsInOrderOfMostIncreasedPercentage
{
    NSArray *measurementsInOrderOfMostIncreasedPercentage = [NSMutableArray array];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *allMoles = [self.context executeFetchRequest:request error:&error];
    
    NSMutableArray *arrayOfMeasurementMetadata = [NSMutableArray array];
    
    for (Mole *mole in allMoles)
    {
        NSMutableDictionary *measurementMetadata = [NSMutableDictionary dictionary];
        
        NSSet *measurementsForMole = mole.measurements;
        if (measurementsForMole.count == 0)
        {
            continue; //If no measurements for a given mole, don't include in the changed list
        }
        else if (measurementsForMole.count == 1) //Only 1 measurement, so no basis for comparison: 0% change
        {
            Measurement *onlyMeasurement = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
            
            [measurementMetadata setValue:mole.moleName forKey:@"name"];
            [measurementMetadata setValue:onlyMeasurement.absoluteMoleDiameter forKey:@"size"];
            [measurementMetadata setValue:@0 forKey:@"percentChange"];
            [measurementMetadata setValue:onlyMeasurement forKey:@"measurement"];
        }
        else if (measurementsForMole.count > 1)
        {
            Measurement *mostRecentMeasurement = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
            NSNumber *percentChange = [self percentChangeInSizeForMole:mole];
            
            [measurementMetadata setValue:mole.moleName forKey:@"name"];
            [measurementMetadata setValue:mostRecentMeasurement.absoluteMoleDiameter forKey:@"size"];
            [measurementMetadata setValue:percentChange forKey:@"percentChange"];
            [measurementMetadata setValue:mostRecentMeasurement forKey:@"measurement"];
        }
        else {NSLog(@"Strange situaiton in which you have a negative return value for fetching measurements for a mole.");}
    
        [arrayOfMeasurementMetadata addObject:measurementMetadata];
    }
    
    NSSortDescriptor *sortByPercent = [[NSSortDescriptor alloc] initWithKey:@"percentChange" ascending:YES];
    //sortByPercent = [sortByPercent reversedSortDescriptor];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByPercent];
    measurementsInOrderOfMostIncreasedPercentage = [arrayOfMeasurementMetadata sortedArrayUsingDescriptors:sortDescriptors];
    
    return measurementsInOrderOfMostIncreasedPercentage;
}

-(NSNumber *)percentChangeInSizeForMole:(Mole *)mole
{
    NSNumber *percentChange = @0;
    Measurement *initial = [Measurement getInitialMoleMeasurementForMole:mole withContext:self.context];
    Measurement *mostRecent = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
    float initialDiameter = [initial.absoluteMoleDiameter floatValue];
    float mostRecentDiameter = [mostRecent.absoluteMoleDiameter floatValue];
    //Round the floating point values so that small changes in size don't look out of place due mismatch between user-visible measurement (1 decimal) vs. behind the scenes precision
    
    float initialRounded = ceilf(initialDiameter * 10.0f) / 10.0f;
    float mostRecentRounded = ceilf(mostRecentDiameter * 10.0f) / 10.0f;
    
    if (initialDiameter && mostRecentDiameter && initialDiameter != 0.0f)
    {
        float percentChangeFloat = ((mostRecentRounded / initialRounded) * 100.0f) - 100.0f;
        percentChange = [NSNumber numberWithFloat:percentChangeFloat];
    }
    return percentChange;
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

-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
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
