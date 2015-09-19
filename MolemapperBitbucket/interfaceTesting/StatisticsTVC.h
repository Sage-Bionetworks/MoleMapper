//
//  StatisticsTVC.h
//  MoleMapper
//
//  Created by Dan Webster on 12/9/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
