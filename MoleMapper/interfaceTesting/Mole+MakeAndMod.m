//
//  Mole+MakeAndMod.m
//  
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


#import "Mole+MakeAndMod.h"
#import "AppDelegate.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"

@implementation Mole (MakeAndMod)

//Mole 'Constructor method' for making a new mole from scratch
+ (Mole *)moleWithMoleID:(NSNumber *)moleID
            withMoleName:(NSString *)moleName
                   atMoleX:(NSNumber *)moleX
                   atMoleY:(NSNumber *)moleY
                    inZone:(Zone *)whichZone
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Mole *mole = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"moleID = %@", moleID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches)
    {
        //NSLog(@"Couldn't fetch any matches from moleAtLocation...");
    }
    else if ([matches count] > 1)
    {
        NSLog(@"Pulled out more than 1 match for mole: %@",moleName);
    }
    else if ([matches count] == 0)
    {
        mole = [NSEntityDescription insertNewObjectForEntityForName:@"Mole"
                                             inManagedObjectContext:context];
        
        mole.moleID = moleID;
        mole.moleName = moleName;
        if (moleX) {mole.moleX = moleX;}
        if (moleX) {mole.moleY = moleY;}
        mole.whichZone = whichZone;
    }
    else
    {
        mole = [matches lastObject];
        if (moleX) {mole.moleX = moleX;}
        if (moleY) {mole.moleY = moleY;}
    }
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
    return mole;
}

//COMMENTED OUT BECAUSE NOW YOU CAN'T GET JUST ONE IMAGE FROM A MOLEID, THERE ARE POTENTIALLY MORE
//Adapted from code found here: http://stackoverflow.com/questions/6821517/save-an-image-to-application-documents-folder-from-uiview-on-ios
//+ (UIImage *)imageForMoleID:(NSNumber *)moleID
//{
//    UIImage *image = nil;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
//    NSString *imageName = [[moleID stringValue] stringByAppendingString:@".png"];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
//    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
//    image = [UIImage imageWithData:pngData];
//    return image;
//}

+ (NSArray *)getAllMolesInCoreDatainManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
}

+ (UIImage *)mostRecentMeasurementImageForMole:(Mole *)mole inContext:(NSManagedObjectContext *)context
{
    UIImage *image = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", mole];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Measurement *mostRecentMeasurement = [matches firstObject];
    NSData *pngData = [NSData dataWithContentsOfFile:mostRecentMeasurement.measurementPhoto];
    image = [UIImage imageWithData:pngData];
    return image;
}

+ (NSData *)mostRecentMeasurementDataForMole:(Mole *)mole inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", mole];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Measurement *mostRecentMeasurement = [matches firstObject];
    NSData *pngData = [NSData dataWithContentsOfFile:mostRecentMeasurement.measurementPhoto];
    return pngData;
}

+ (int)getNextValidMoleID
{
    int moleID = nil;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (![standardUserDefaults integerForKey:@"nextMoleID"])
    {
        //NSLog(@"For some reason, haven't established NSUserDefaults");
    }
    else
    {
        int validMoleID = (int)[standardUserDefaults integerForKey:@"nextMoleID"];
        moleID = validMoleID;
        int nextValidMoleID;
        validMoleID++;
        nextValidMoleID = validMoleID;
        [standardUserDefaults setInteger:nextValidMoleID forKey:@"nextMoleID"];
    }
    return moleID;
}

@end
