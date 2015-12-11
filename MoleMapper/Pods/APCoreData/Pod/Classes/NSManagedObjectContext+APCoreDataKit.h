//
//  NSManagedObjectContext+APCoreDataKit.h
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (APCoreDataKit)

/// Contexts
+ (NSManagedObjectContext *)ap_managedObjectContext;
+ (NSManagedObjectContext *)ap_backgroundManagedObjectContext;

/// Save
- (void)ap_save;

@end
