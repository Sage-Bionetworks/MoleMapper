//
//  APCDKManagedTableViewController.m
//
//  Created by Andrew Podkovyrin on 18/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "APCDKManagedTableViewController.h"

#define APCDK_MAX_FRC_CHANGES_COUNT 50


@interface APCDKManagedTableViewController ()

@property (assign, readwrite, nonatomic) UITableViewStyle tableViewStyle;
@property (strong, readwrite, nonatomic) UITableView *tableView;

// FRC queued updates
@property (strong, readwrite, nonatomic) NSMutableIndexSet *deletedSectionIndexes;
@property (strong, readwrite, nonatomic) NSMutableIndexSet *insertedSectionIndexes;
@property (strong, readwrite, nonatomic) NSMutableArray *deletedRowIndexPaths;
@property (strong, readwrite, nonatomic) NSMutableArray *insertedRowIndexPaths;
@property (strong, readwrite, nonatomic) NSMutableArray *updatedRowIndexPaths;

@end


@implementation APCDKManagedTableViewController

#pragma mark - NSObject

- (instancetype)init {
    self = [self initWithStyle:UITableViewStylePlain];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.tableViewStyle = style;
        self.clearsSelectionOnViewWillAppear = YES;
    }
    return self;
}

- (void)dealloc {
	self.tableView.dataSource = nil;
	self.tableView.delegate = nil;
}

#pragma mark - Lifecycle

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.clearsSelectionOnViewWillAppear) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
    
	[self.tableView setEditing:editing animated:animated];
}

#pragma mark - Callbacks

- (void)didCreateFetchedResultsController {
    [super didCreateFetchedResultsController];
    
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.name;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.animateFetchedResultsControllerChanges) {
        return;
    }
    
    if (type == NSFetchedResultsChangeInsert) {
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
            return;
        }
        
        [self.insertedRowIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
    } else if (type == NSFetchedResultsChangeMove) {
        if (![self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
        }
        
        if (![self.deletedSectionIndexes containsIndex:indexPath.section]) {
            [self.deletedRowIndexPaths addObject:indexPath];
        }
    } else if (type == NSFetchedResultsChangeUpdate) {
        [self.updatedRowIndexPaths addObject:indexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    if (!self.animateFetchedResultsControllerChanges) {
        return;
    }
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex];
            break;
        default:
            ; // Shouldn't have a default
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    
    NSInteger totalChangesCount = self.deletedSectionIndexes.count +
        self.insertedSectionIndexes.count +
        self.deletedRowIndexPaths.count +
        self.insertedRowIndexPaths.count +
        self.updatedRowIndexPaths.count;
    
	if (self.animateFetchedResultsControllerChanges && totalChangesCount < APCDK_MAX_FRC_CHANGES_COUNT) {
        [self.tableView beginUpdates];
        
        [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
	} else {
        [self.tableView reloadData];
    }
    
    [self resetQueuedChanges];
}

#pragma mark - FRC queued lazy getters

- (NSMutableIndexSet *)deletedSectionIndexes {
    if (_deletedSectionIndexes == nil) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    if (_insertedSectionIndexes == nil) {
        _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _insertedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths {
    if (_deletedRowIndexPaths == nil) {
        _deletedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths {
    if (_insertedRowIndexPaths == nil) {
        _insertedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths {
    if (_updatedRowIndexPaths == nil) {
        _updatedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _updatedRowIndexPaths;
}

- (void)resetQueuedChanges {
    // nil out the collections so they are ready for their next use.
    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
}

@end
