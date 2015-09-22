//
//  APCDKManagedViewController.h
//
//  Created by Andrew Podkovyrin on 18/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface APCDKManagedViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, readonly, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, readwrite, nonatomic) BOOL animateFetchedResultsControllerChanges;
@property (assign, readwrite, nonatomic, getter=isLoading) BOOL loading;

/// Configuration
- (NSFetchRequest *)fetchRequest;
- (Class)fetchRequestEntityClass;
- (NSArray *)fetchRequestSortDescriptors;
- (NSPredicate *)fetchRequestPredicate;
- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)fetchedResultsControllerSectionNameKeyPath;
- (NSString *)fetchedResultsControllerCacheName;

/// State
- (BOOL)hasContent;

/// Callbacks
- (void)didCreateFetchedResultsController;

/// Loading view
- (void)showLoadingView;
- (void)hideLoadingView;

/// Placeholder view
- (void)showPlaceholderView;
- (void)hidePlaceholderView;

@end
