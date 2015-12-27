//
//  MoleMeasurement+MakeAndMod.m
//
//  Created by Dan Webster on 7/5/13.
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
