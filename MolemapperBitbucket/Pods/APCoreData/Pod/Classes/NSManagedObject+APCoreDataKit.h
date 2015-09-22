//
//  NSManagedObject+APCoreDataKit.h
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (APCoreDataKit)

/// Entity
+ (NSString *)ap_entityName;
+ (NSEntityDescription *)ap_entityDescriptionInContext:(NSManagedObjectContext *)context;

/// Create
+ (instancetype)ap_createInContext:(NSManagedObjectContext *)context;

/// Delete
- (void)ap_delete;
- (void)ap_deleteInContext:(NSManagedObjectContext *)context;

/// Fetch
+ (NSFetchRequest *)ap_createFetchRequestInContext:(NSManagedObjectContext *)context;
+ (NSArray *)ap_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

/// Find
+ (instancetype)ap_findByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context;

/// Mixed
+ (instancetype)ap_findOrCreateByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context;

/// Thread
- (instancetype)ap_inContext:(NSManagedObjectContext *)context;

@end


#pragma mark - Mogenerator

@protocol APDataKitMogeneratorMethods <NSObject>

@optional
+ (NSString *)entityName;
- (instancetype)entityInManagedObjectContext:(NSManagedObjectContext *)object;
- (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)object;

@end

