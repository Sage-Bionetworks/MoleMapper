//
//  APCoreDataStack.m
//
//  Created by Andrew Podkovyrin on 16/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "APCoreDataStack.h"


@interface APCoreDataStack ()

@property (strong, readwrite, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readwrite, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;

@end


@implementation APCoreDataStack

+ (APCoreDataStack *)sharedInstance {
	static dispatch_once_t pred;
	static APCoreDataStack *sharedInstance = nil;
	dispatch_once(&pred, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.managedObjectContext = [[self class] managedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        
        self.backgroundManagedObjectContext = [[self class] managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.backgroundManagedObjectContext.undoManager = nil;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                          object:self.backgroundManagedObjectContext
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          NSManagedObjectContext *moc = self.managedObjectContext;
                                                          [moc performBlock:^{
                                                              [moc mergeChangesFromContextDidSaveNotification:note];
                                                          }];
                                                      }];
    }
    return self;
}

#pragma mark - MOC Factory

+ (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    
    NSManagedObjectModel *managedObjectModel = [self managedObjectModel];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSError *error = nil;
    [persistentStoreCoordinator addPersistentStoreWithType:[self persistentStoreType]
                                             configuration:nil
                                                       URL:[self persistentStoreURL]
                                                   options:[self persistentStoreOptions]
                                                     error:&error];
    if (error) {
        APCDKLog(@"managedObjectContextWithConcurrencyType: %@", error);
    }
    
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    return managedObjectContext;
}

#pragma mark - Configuration

+ (NSString *)persistentStoreType {
	return NSSQLiteStoreType;
}

+ (NSDictionary *)persistentStoreOptions {
    return @{
             NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSInferMappingModelAutomaticallyOption: @YES
             };
}

+ (NSURL *)persistentStoreURL {
    NSString *appName = [[NSBundle bundleForClass:[self class]] infoDictionary][(NSString *)kCFBundleNameKey];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", appName]];
    return url;
}

+ (NSManagedObjectModel *)managedObjectModel {
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    return model;
}

@end
