//
//  APCoreDataStack.h
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


#ifndef APCDK_ENABLE_LOGGING
    #ifdef DEBUG
        #define APCDK_ENABLE_LOGGING 1
    #else
        #define APCDK_ENABLE_LOGGING 0
    #endif /* DEBUG */
#endif /* APCDK_ENABLE_LOGGING */

#if APCDK_ENABLE_LOGGING
    #define APCDKLog(...)          NSLog(@"APCoreDataKit: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
    #define APCDKLog(...)
#endif /* APCDK_ENABLE_LOGGING */


@interface APCoreDataStack : NSObject

@property (strong, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;

+ (APCoreDataStack *)sharedInstance;

@end
