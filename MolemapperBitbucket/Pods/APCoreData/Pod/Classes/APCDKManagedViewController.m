//
//  APCDKManagedViewController.m
//
//  Created by Andrew Podkovyrin on 18/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "APCDKManagedViewController.h"
#import "NSManagedObject+APCoreDataKit.h"


@interface APCDKManagedViewController ()

@property (strong, readwrite, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end


@implementation APCDKManagedViewController

#pragma mark - NSObject

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.animateFetchedResultsControllerChanges = YES;
    }
    return self;
}

- (void)dealloc {
	self.fetchedResultsController = nil;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self resetLoadingPlaceholderViewsState];
}

#pragma mark - FetchedResultsController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
                                                                        managedObjectContext:[self managedObjectContext]
                                                                          sectionNameKeyPath:[self fetchedResultsControllerSectionNameKeyPath]
                                                                                   cacheName:[self fetchedResultsControllerCacheName]];
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
        
        [self didCreateFetchedResultsController];
    }
    return _fetchedResultsController;
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	_fetchedResultsController.delegate = nil;
	_fetchedResultsController = fetchedResultsController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self resetLoadingPlaceholderViewsState];
}

#pragma mark - FetchedResultsController Configuration

- (NSFetchRequest *)fetchRequest {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [[self fetchRequestEntityClass] ap_entityDescriptionInContext:[self managedObjectContext]];
	fetchRequest.sortDescriptors = [self fetchRequestSortDescriptors];
	fetchRequest.predicate = [self fetchRequestPredicate];
	return fetchRequest;
}

- (Class)fetchRequestEntityClass {
	return [NSManagedObject class];
}

- (NSArray *)fetchRequestSortDescriptors {
	return nil;
}

- (NSPredicate *)fetchRequestPredicate {
	return nil;
}

- (NSManagedObjectContext *)managedObjectContext {
    return nil;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath {
	return nil;
}

- (NSString *)fetchedResultsControllerCacheName {
	return nil; // nil means no cache file
}

#pragma mark - State

- (BOOL)hasContent {
	return self.fetchedResultsController.fetchedObjects.count > 0;
}

#pragma mark - Callbacks

- (void)didCreateFetchedResultsController {
    // reloadData here
}

#pragma mark - Additional views

- (void)resetLoadingPlaceholderViewsState {
    if ([self hasContent]) {
        [self hideLoadingView];
        [self hidePlaceholderView];
    } else {
        if (self.isLoading) {
            [self hidePlaceholderView];
            [self showLoadingView];
        } else {
            [self hideLoadingView];
            [self showPlaceholderView];
        }
    }
}

#pragma mark - Loading view

- (void)showLoadingView {
    
}

- (void)hideLoadingView {
    
}

#pragma mark - Placeholder view

- (void)showPlaceholderView {
    
}

- (void)hidePlaceholderView {
    
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    [self resetLoadingPlaceholderViewsState];
}

@end
