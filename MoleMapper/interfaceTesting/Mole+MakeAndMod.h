//
//  Mole+MakeAndMod.h
//  
//
//  Created by Dan Webster on 7/5/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "Mole.h"

@interface Mole (MakeAndMod)
//Mole 'Constructor method' for making a new mole from scratch
+ (Mole *)moleWithMoleID:(NSNumber *)moleID
            withMoleName:(NSString *)moleName
                 atMoleX:(NSNumber *)moleX
                 atMoleY:(NSNumber *)moleY
                  inZone:(Zone *)whichZone
  inManagedObjectContext:(NSManagedObjectContext *)context;

//Will grab image (.png) from Documents directory containing most recent mole measurement image
+ (UIImage *)mostRecentMeasurementImageForMole:(Mole *)mole inContext:(NSManagedObjectContext *)context;

+ (int)getNextValidMoleID;

+ (NSArray *)getAllMolesInCoreDatainManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSData *)mostRecentMeasurementDataForMole:(Mole *)mole inContext:(NSManagedObjectContext *)context;

@end
