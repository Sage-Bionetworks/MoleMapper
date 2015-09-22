//
//  NSManagedObjectContext+APDataKit.m
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "NSManagedObjectContext+APCoreDataKit.h"
#import "APCoreDataStack.h"

@implementation NSManagedObjectContext (APCoreDataKit)

#pragma mark - Contexts

+ (NSManagedObjectContext *)ap_managedObjectContext {
    return [APCoreDataStack sharedInstance].managedObjectContext;
}

+ (NSManagedObjectContext *)ap_backgroundManagedObjectContext {
    return [APCoreDataStack sharedInstance].backgroundManagedObjectContext;
}

#pragma mark - Save

- (void)ap_save {
    NSError *error = nil;
    [self save:&error];
    if (error) {
        APCDKLog(@"ap_saveWithBlock: %@", error);
    }
}

@end
