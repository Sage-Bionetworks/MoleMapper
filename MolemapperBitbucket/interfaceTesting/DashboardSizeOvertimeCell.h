//
//  DashboardSizeOvertimeCell.h
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardSizeOvertimeCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain)  IBOutlet UITableView *tableViewInside;
@property NSInteger rowNumber;
@property NSDictionary* allMolesDicitionary;

@end
