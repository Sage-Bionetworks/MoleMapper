//
//  NSManagedObject+APCoreDataKit.m
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "NSManagedObject+APCoreDataKit.h"
#import "APCoreDataStack.h"

@implementation NSManagedObject (APCoreDataKit)

#pragma mark - Entity

+ (NSString *)ap_entityName {
    return NSStringFromClass(self);
}

+ (NSEntityDescription *)ap_entityDescriptionInContext:(NSManagedObjectContext *)context {
    if ([self respondsToSelector:@selector(entityInManagedObjectContext:)]) {
        NSEntityDescription *entity = [self performSelector:@selector(entityInManagedObjectContext:) withObject:context];
        return entity;
    } else {
        NSString *entityName = [self ap_entityName];
        return [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    }
}

#pragma mark - Create

+ (instancetype)ap_createInContext:(NSManagedObjectContext *)context {
    if ([self respondsToSelector:@selector(insertInManagedObjectContext:)]) {
        id entity = [self performSelector:@selector(insertInManagedObjectContext:) withObject:context];
        return entity;
    } else {
        return [NSEntityDescription insertNewObjectForEntityForName:[self ap_entityName] inManagedObjectContext:context];
    }
}

#pragma mark - Delete

- (void)ap_delete {
	[self ap_deleteInContext:self.managedObjectContext];
}

- (void)ap_deleteInContext:(NSManagedObjectContext *)context {
    [context deleteObject:self];
}

#pragma mark - Fetch

+ (NSFetchRequest *)ap_createFetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [self ap_entityDescriptionInContext:context];
    return request;
}

+ (NSArray *)ap_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context {
    __block NSArray *results = nil;
    void (^requestBlock)(void) = ^{
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
        
        if (error) {
            APCDKLog(@"ap_executeFetchRequest:inContext: %@", error);
        }
    };
    
    if ([context concurrencyType] == NSConfinementConcurrencyType) {
        requestBlock();
    } else {
        [context performBlockAndWait:requestBlock];
    }
	return results;
}

#pragma mark - Find

+ (instancetype)ap_findByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self ap_createFetchRequestInContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
    request.fetchLimit = 1;
    NSArray *results = [self ap_executeFetchRequest:request inContext:context];
    return results.firstObject;
}

#pragma mark - Mixed

+ (instancetype)ap_findOrCreateByAttribute:(NSString *)attribute value:(id)value context:(NSManagedObjectContext *)context {
    NSManagedObject *object = [self ap_findByAttribute:attribute value:value context:context];
    if (!object) {
        object = [self ap_createInContext:context];
        [object setValue:value forKey:attribute];
    }
    return object;
}

#pragma mark - Threads

- (instancetype)ap_inContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    NSManagedObject *objectInContext = [context existingObjectWithID:self.objectID error:&error];
    if (error) {
        APCDKLog(@"ap_inContext: %@", error);
    }
    return objectInContext;
}

@end
