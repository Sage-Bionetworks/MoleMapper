//
//  Zone.h
//  MoleMapper
//
//  Created by Dan Webster on 9/11/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Mole;

@interface Zone : NSManagedObject

@property (nonatomic, retain) NSString * zoneID;
@property (nonatomic, retain) NSString * zonePhoto;
@property (nonatomic, retain) NSSet *moles;
@end

@interface Zone (CoreDataGeneratedAccessors)

- (void)addMolesObject:(Mole *)value;
- (void)removeMolesObject:(Mole *)value;
- (void)addMoles:(NSSet *)values;
- (void)removeMoles:(NSSet *)values;

@end
