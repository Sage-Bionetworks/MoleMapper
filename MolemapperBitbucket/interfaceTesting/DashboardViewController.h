//
//  DashboardViewController.h
//  MoleMapper
//
//  Created by Dan Webster on 8/16/15.
//  Edited by István Karpács
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

//org.ANCRapps.MoleMapper

#import <UIKit/UIKit.h>

@class DashboardSizeOvertimeCell;

@interface DashboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet DashboardSizeOvertimeCell *sizeOvertimeWithTableView;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property NSMutableArray* cellList;

@end
