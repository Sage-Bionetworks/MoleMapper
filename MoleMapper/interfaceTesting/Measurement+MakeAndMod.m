//
//  MoleMeasurement+MakeAndMod.m
//  interfaceTesting
//
//  Created by Dan Webster on 7/5/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "Measurement+MakeAndMod.h"
#import "Measurement.h"
#import "AppDelegate.h"
#import "Mole+MakeAndMod.h"
#import "Mole.h"

@implementation Measurement (MakeAndMod)

+ (Measurement *)moleMeasurementForMole:(Mole *)whichMole
                               withDate:(NSDate *)date
                              withPhoto:(NSString *)measurementPhoto
                withMeasurementDiameter:(NSNumber *)measurementDiameter
                       withMeasurementX:(NSNumber *)measurementX
                       withMeasurementY:(NSNumber *)measurementY
                  withReferenceDiameter:(NSNumber *)referenceDiameter
                         withReferenceX:(NSNumber *)referenceX
                         withReferenceY:(NSNumber *)referenceY
                      withMeasurementID:(NSString *)measurementID
          withAbsoluteReferenceDiameter:(NSNumber *)absoluteReferenceDiameter
               withAbsoluteMoleDiameter:(NSNumber *)absoluteMoleDiameter
                    withReferenceObject:(NSString *)referenceObject
                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    Measurement *mm = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichMole" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"measurementID = %@", measurementID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches)
    {
        //no measurements for this mole
    }
    
    if ([matches count] == 1)
    {

        mm = [matches lastObject];
        if (measurementDiameter) {mm.measurementDiameter = measurementDiameter;}
        if (measurementX) {mm.measurementX = measurementX;}
        if (measurementY) {mm.measurementY = measurementY;}
        if (referenceDiameter) {mm.referenceDiameter = referenceDiameter;}
        if (referenceX) {mm.referenceX = referenceX;}
        if (referenceY) {mm.referenceY = referenceY;}
        if (absoluteReferenceDiameter) {mm.absoluteReferenceDiameter = absoluteReferenceDiameter;}
        if (absoluteMoleDiameter) {mm.absoluteMoleDiameter = absoluteMoleDiameter;}
        if (referenceObject) {mm.referenceObject = referenceObject;}
    }

    if ([matches count] == 0)
    {
        mm = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement"
                                             inManagedObjectContext:context];
        
        mm.whichMole = whichMole;
        mm.measurementPhoto = measurementPhoto;
        mm.date = date;
        mm.measurementDiameter = measurementDiameter;
        mm.measurementX = measurementX;
        mm.measurementY = measurementY;
        mm.referenceDiameter = referenceDiameter;
        mm.referenceX = referenceX;
        mm.referenceY = referenceY;
        mm.measurementID = measurementID;
        mm.absoluteReferenceDiameter = absoluteReferenceDiameter;
        mm.absoluteMoleDiameter = absoluteMoleDiameter;
        mm.referenceObject = referenceObject;
        return mm;
    }

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
    return mm;
}


+ (NSString *)imageFullPathNameForMeasurement:(Measurement *)measurement
{
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *measurementID = measurement.measurementID;
    return [NSString stringWithFormat:@"%@/%@",docsDirectory,measurementID];
    
}

//Adapted from code found here: http://stackoverflow.com/questions/6821517/save-an-image-to-application-documents-folder-from-uiview-on-ios
+ (UIImage *)imageForMeasurement:(Measurement *)measurement
{
    NSString *imageFullPathName = [Measurement imageFullPathNameForMeasurement:measurement];
    NSData *pngData = [NSData dataWithContentsOfFile:imageFullPathName];
    UIImage *image = [UIImage imageWithData:pngData];
    return image;
}

+ (NSData *)rawPngDataForMeasurement:(Measurement *)measurement
{
    NSString *imageFullPathName = [Measurement imageFullPathNameForMeasurement:measurement];
    NSData *pngData = [NSData dataWithContentsOfFile:imageFullPathName];
    return pngData;
}

+ (BOOL)hasValidMeasurementInfoForMeasurement:(Measurement *)measurement;
{
    BOOL hasValidMeasurementInfo = YES;
    if (measurement == nil) {hasValidMeasurementInfo = NO;}
    if ([measurement.measurementX doubleValue] == 0.0 && [measurement.measurementY doubleValue] == 0.0) {hasValidMeasurementInfo = NO;}
    if ([measurement.referenceX doubleValue] == 0.0 && [measurement.referenceY doubleValue] == 0.0) {hasValidMeasurementInfo = NO;}
    if ([measurement.measurementDiameter doubleValue] == 0.0) {hasValidMeasurementInfo = NO;}
    if ([measurement.referenceDiameter doubleValue] == 0.0) {hasValidMeasurementInfo = NO;}
    return hasValidMeasurementInfo;
}

+ (Measurement *)getMostRecentMoleMeasurementForMole:(Mole *)mole withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole.moleID = %@", mole.moleID];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    Measurement *mostRecentMeasurement = [matches firstObject];
    return mostRecentMeasurement;    
}

+ (Measurement *)getInitialMoleMeasurementForMole:(Mole *)mole withContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole.moleID = %@", mole.moleID];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    Measurement *initialMeasurement = [matches lastObject];
    return initialMeasurement;
}

//Calculates the absolute mole diameter in millimeters (mm) from the measurements in points (pts) following formula below:
/*
 abs measurement diameter (mm) / abs ref diameter (mm) = measurement pts / ref pts
 therefore,
 measurement diameter (mm) = ((abs ref diameter * measurement pts) / ref pts)
 */
+ (NSNumber *)calculateAbsoluteMoleDiameterFromMeasurementDiameter:(NSNumber *)measurementDiameter
                                             withReferenceDiameter:(NSNumber *)referenceDiameter
                                     withAbsoluteReferenceDiameter:(NSNumber *)absoluteReferenceDiameter;
{
    float moleDiamInMM;
    float moleDiameterInPts = [measurementDiameter floatValue];
    float referenceDiameterInPts = [referenceDiameter floatValue];
    float referenceDiameterInMM = [absoluteReferenceDiameter floatValue];
    
    moleDiamInMM = (referenceDiameterInMM * moleDiameterInPts) / referenceDiameterInPts;
    
    NSNumber *absoluteMoleDiameter = [NSNumber numberWithFloat:moleDiamInMM];
    return absoluteMoleDiameter;
}


@end
