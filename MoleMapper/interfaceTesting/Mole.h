//
//  Mole.h
//  MoleMapper
//
//  Created by Dan Webster on 9/11/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MoleMeasurement, Zone;

@interface Mole : NSManagedObject

@property (nonatomic, retain) NSString * moleName;
@property (nonatomic, retain) NSNumber * moleX;
@property (nonatomic, retain) NSNumber * moleY;
@property (nonatomic, retain) NSNumber * moleID;
@property (nonatomic, retain) NSSet *measurements;
@property (nonatomic, retain) Zone *whichZone;
@end

@interface Mole (CoreDataGeneratedAccessors)

- (void)addMeasurementsObject:(MoleMeasurement *)value;
- (void)removeMeasurementsObject:(MoleMeasurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

@end
