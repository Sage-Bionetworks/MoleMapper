//
//  Mole+MakeAndMod.m
//  
//
//  Created by Dan Webster on 7/5/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
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
