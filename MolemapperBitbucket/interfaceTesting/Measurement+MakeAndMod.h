//
//  MoleMeasurement+MakeAndMod.h
//  interfaceTesting
//
//  Created by Dan Webster on 7/5/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "Measurement.h"

/*
 Note: An measurement is only taken if:
 1. A picture of the mole has been taken using the MoleViewController screen, 
 2. A viewWillDisappear has been called on the MoleViewController 
 
 These 2 conditions denote that the user has at least had the chance to look at the measurement tools 
 overlain on the picture of the mole/reference.  It is saved/stored if these 2 conditions are met
*/

@interface Measurement (MakeAndMod)

//create a new mole measurement with provided parameters or fetch an existing mole measurement based
//on measurementID
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
                 inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSData *)rawPngDataForMeasurement:(Measurement *)measurement;

+ (NSString *)imageFullPathNameForMeasurement:(Measurement *)measurement;

+ (UIImage *)imageForMeasurement:(Measurement *)measurement;

//Checks if measurement is non-nil and has measurement values (x,y,diameter) that are non-zero
+ (BOOL)hasValidMeasurementInfoForMeasurement:(Measurement *)measurement;

+ (Measurement *)getMostRecentMoleMeasurementForMole:(Mole *)mole withContext:(NSManagedObjectContext *)context;

//Calculates the absolute mole diameter in millimeters (mm) from the measurements in points (pts) following formula below:
/*
 abs measurement diameter (mm) / abs ref diameter (mm) = measurement pts / ref pts
 therefore,
 measurement diameter (mm) = ((abs ref diameter * measurement pts) / ref pts)
 */
+ (NSNumber *)calculateAbsoluteMoleDiameterFromMeasurementDiameter:(NSNumber *)measurementDiameter
                                             withReferenceDiameter:(NSNumber *)referenceDiameter
                                     withAbsoluteReferenceDiameter:(NSNumber *)absoluteReferenceDiameter;

@end
