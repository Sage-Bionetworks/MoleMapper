//
//  DashboardModel.m
//  MoleMapper
//
//  Created by Andy Yeung on 9/12/15.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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

-(instancetype)initModel{
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
        _sharedObject = [[self alloc] initModel];
    });
    
    return _sharedObject;
}

-(void) refreshContext
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = ad.managedObjectContext;
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
        else if (measurementsForMole.count > 0) //Has at least one measurement
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
        
        for (Mole *mole in allMoles)
        {
            Measurement *mostRecent = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
            if (mostRecent)
            {
                NSDate *dateOfMeasurement = mostRecent.date;
                if ([self date:dateOfMeasurement isBetweenDate:lastTimeAsurveyWasTaken andDate:now])
                {
                    numberOfMolesMeasuredSinceLastFollowup++;
                }
            }
        }
    }
    
    return [NSNumber numberWithInt:numberOfMolesMeasuredSinceLastFollowup];
}

-(NSInteger) getAllZoneNumber
{
    //This needs to be (- 2) because the head detail in front and back is double-counted and has no actual measurement
    return [[Zone allZoneIDs] count] - 2;
}

-(UIColor*) getColorForHeader
{
    //203,229,255
    /*float rateRed = (203.0f / 255.0f) / (0.01f / 255.0f);
    float rateGreen = (229.0f / 255.0f) / (122.0f / 255.0f);
    
    UIColor* c = [self getColorForDashboardTextAndButtons];
    CGColorRef color = [c CGColor];
    
    int numComponents = (int)CGColorGetNumberOfComponents(color);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red = components[0];
        CGFloat green = components[1];
        //CGFloat blue = components[2];
        //CGFloat alpha = components[3];
        
        red /= rateRed;
        green /= rateGreen;
        
        c = [UIColor colorWithRed:red green:green blue:1.0 alpha:1.0];
    }*/
    
    UIColor* c = [UIColor colorWithRed:234 / 255.0 green:239.0 / 255.0 blue:1.0 alpha:1.0];
    return  c;
}

-(UIColor*) getColorForDashboardTextAndButtons
{
    UIColor* c = [UIColor colorWithRed:0 / 255.0 green:122.0 / 255.0 blue:1.0 alpha:1.0];
    return  c;
}

-(NSNumber *)daysUntilNextMeasurementPeriod
{
    NSDate *now = [NSDate date];
    NSDate *lastTimeAsurveyWasTaken;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    lastTimeAsurveyWasTaken = [ud valueForKey:@"dateOfLastSurveyCompleted"];
    
    NSInteger daysSinceLastSurvey = [self daysBetweenDate:lastTimeAsurveyWasTaken andDate:now];
    NSInteger daysUntilNextMeasurementPeriod = daysSinceLastSurvey % numberOfDaysInFollowupPeriod;
    daysUntilNextMeasurementPeriod = numberOfDaysInFollowupPeriod - daysUntilNextMeasurementPeriod;
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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *allMoles = [self.context executeFetchRequest:request error:&error];
    
    for (Mole *mole in allMoles)
    {
        Measurement *measure = [Measurement getMostRecentMoleMeasurementForMole:mole withContext:self.context];
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
// [{"name": zoneName, "count": numberOfMolesInZone(NSNumber)}, "zone" : Zone object]
-(NSArray *)zoneNameToNumberOfMolesInZoneDictionary
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *arrayOfDictionaries = [NSMutableArray array];
    for (Zone *zone in matches)
    {
        NSSet *moles = zone.moles;
        int moleNum = (int)[moles count];
        
        //Skip zones with no moles
        if (moleNum == 0) {continue;}
        NSNumber *numberOfMoles = [NSNumber numberWithInt:moleNum];
        NSNumber *zoneID = @([zone.zoneID intValue]);
        NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
        
        NSMutableDictionary *zonesToMoles = [NSMutableDictionary dictionary];
        [zonesToMoles setValue:zoneName forKey:@"name"];
        [zonesToMoles setValue:numberOfMoles forKey:@"numberOfMolesInZone"];
        [zonesToMoles setValue:zoneID forKey:@"zone"];

        [arrayOfDictionaries addObject:zonesToMoles];
    }
    
    NSSortDescriptor *sortByMoles = [[NSSortDescriptor alloc] initWithKey:@"numberOfMolesInZone" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByMoles];
    return [arrayOfDictionaries sortedArrayUsingDescriptors:sortDescriptors];
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
    sortByPercent = [sortByPercent reversedSortDescriptor];
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
    
    //float initialRounded = [self correctFloat:initialDiameter];
    //float mostRecentRounded = [self correctFloat:mostRecentDiameter];

    if (initialDiameter && mostRecentDiameter && initialDiameter != 0.0f)
    {
        float percentChangeFloat = -1.0 * (((initialDiameter - mostRecentDiameter)/ initialDiameter) * 100.0f);
        //float percentChangeFloat = ((mostRecentDiameter / initialDiameter) * 100.0f) - 100.0f;
        //float percentChangeFloat = ((mostRecentRounded / initialRounded) * 100.0f) - 100.0f;
        float correctlyRoundedFloat = [self correctFloat:percentChangeFloat];
        percentChange = [NSNumber numberWithFloat:correctlyRoundedFloat];
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

-(float) correctFloat:(float) value
{
    return floorf(value * 10.0f + 0.5) / 10.0f;
}

-(UILabel*) getNoDataLabel
{
    UILabel *noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 0, 0)];
    [noDataLabel setBackgroundColor:[UIColor clearColor]];
    [noDataLabel setText:@"NO DATA AVAILABLE"];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.textColor = [UIColor darkGrayColor];
    
    return noDataLabel;
}

-(NSData *)mostRecentStoredUVdata
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *mostRecentStoredUVdata = [ud objectForKey:@"mostRecentStoredUVdata"];
    return mostRecentStoredUVdata;
}

-(void)setMostRecentStoredUVdata:(NSData *)mostRecentStoredUVdata
{
    if (mostRecentStoredUVdata != nil)
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:mostRecentStoredUVdata forKey:@"mostRecentStoredUVdata"];
    }
}

@end
