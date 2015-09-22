//
//  APCDKManagedTableViewController.h
//
//  Created by Andrew Podkovyrin on 18/04/14.
//  Copyright (c) 2014 Podkovyrin. All rights reserved.
//

#import "APCDKManagedViewController.h"

@interface APCDKManagedTableViewController : APCDKManagedViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, readonly, nonatomic) UITableView *tableView;
@property (assign, readwrite, nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
