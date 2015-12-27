//
//  MoleMeasurement+MakeAndMod.h
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

+ (Measurement *)getInitialMoleMeasurementForMole:(Mole *)mole withContext:(NSManagedObjectContext *)context;

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
