//
//  DashboardViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 8/16/15.
//  Edited by István Karpács
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardActivityCompletionCell.h"
#import "DashboardZoneDocumentationCell.h"
#import "DashBoardMeasurementCell.h"
#import "DashboardBiggestMoleCell.h"
#import "DashboardSizeOvertimeCell.h"
#import "DashboardMolyEstZone.h"
#import "DashboardModel.h"
#import "MoleViewController.h"
#import "AppDelegate.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _cellList = [[NSMutableArray alloc] init];
    [self setupCellList];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moleMapperLogo"]];
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.context = ad.managedObjectContext;
}

-(void) setupCellList
{
    static NSString *cell_id = @"DashboardActivityCompletionCell";
    
    DashboardActivityCompletionCell *cell1 = (DashboardActivityCompletionCell *)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell1 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell1 = [nib objectAtIndex:0];
    }
    
    cell_id = @"DashboardZoneDocumentationCell";
    
    DashboardZoneDocumentationCell *cell2 = (DashboardZoneDocumentationCell *)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell2 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell2 = [nib objectAtIndex:0];
    }
    
    //DashBoardMeasurementCell
    
    cell_id = @"DashBoardMeasurementCell";
    
    DashBoardMeasurementCell *cell3 = (DashBoardMeasurementCell *)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell3 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell3 = [nib objectAtIndex:0];
    }
    
    //DashboardBiggestMoleCell
    cell_id = @"DashboardBiggestMoleCell";
    
    DashboardBiggestMoleCell *cell4 = (DashboardBiggestMoleCell*)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell4 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell4 = [nib objectAtIndex:0];
    }
    
    
    //DashboardSizeOvertimeCell
    cell_id = @"DashboardSizeOvertimeCell";
    
    DashboardSizeOvertimeCell *cell5 = (DashboardSizeOvertimeCell*)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell5 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell5 = [nib objectAtIndex:0];
    }
    
    //DashboardMolyestZone
    cell_id = @"DashboardMolyEstZone";
    
    DashboardMolyEstZone *cell6 = (DashboardMolyEstZone*)[_tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell6 == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cell_id owner:self options:nil];
        cell6 = [nib objectAtIndex:0];
    }
    
    cell1.clipsToBounds = YES;
    cell2.clipsToBounds = YES;
    cell3.clipsToBounds = YES;
    cell4.clipsToBounds = YES;
    cell5.clipsToBounds = YES;
    cell6.clipsToBounds = YES;
    
    [_cellList addObject:cell1];
    [_cellList addObject:cell2];
    [_cellList addObject:cell3];
    [_cellList addObject:cell4];
    [_cellList addObject:cell5];
    [_cellList addObject:cell6];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cellList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0)
    {
        NSNumber* total = [[DashboardModel sharedInstance] totalNumberOfMolesMeasured];
        NSNumber* last = [[DashboardModel sharedInstance] numberOfMolesMeasuredSinceLastFollowup];
        float numb = 0.0;
        if ([total floatValue] > 0.0) {numb = [last floatValue] / [total floatValue];};
        [(DashboardActivityCompletionCell*)[_cellList objectAtIndex:indexPath.row] setDataToProgressView:numb];
    }
    
    if (indexPath.row == 0)
    {
        //[(DashboardZoneDocumentationCell*)[_cellList objectAtIndex:indexPath.row] setDataToProgressView:0.95];
    }
    
    return [_cellList objectAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSNumber *height = 0;

    if (indexPath.row == 0)
    {
        DashboardActivityCompletionCell* cell = (DashboardActivityCompletionCell*)[_cellList objectAtIndex:indexPath.row];
        height = @(cell.bounds.size.height);
    }

    if (indexPath.row == 1)
    {
        DashboardZoneDocumentationCell* cell = (DashboardZoneDocumentationCell*)[_cellList objectAtIndex:indexPath.row];
        height = @(cell.bounds.size.height);
    }
    
    if (indexPath.row == 2)
    {
        DashBoardMeasurementCell* cell = (DashBoardMeasurementCell*)[_cellList objectAtIndex:indexPath.row];
        cell.dashBoardViewController = self;
        height = @(cell.bounds.size.height);
    }
    
    if (indexPath.row == 3)
    {
        DashboardBiggestMoleCell* cell = (DashboardBiggestMoleCell*)[_cellList objectAtIndex:indexPath.row];
        height = @(cell.bounds.size.height);
    }
    
    if (indexPath.row == 4)
    {
        DashboardSizeOvertimeCell* cell = (DashboardSizeOvertimeCell*)[_cellList objectAtIndex:indexPath.row];
        
        //probably nondebug
        NSDictionary *moleDictionary = [[DashboardModel sharedInstance] rankedListOfMoleSizeChangeAndMetadata];
        cell.allMolesDicitionary = moleDictionary;
        cell.dashBoardViewController = self;
        height = @(([moleDictionary count] + 1) * 62);
        
        CGRect bounds = [cell.tableViewInside bounds];
        [cell.tableViewInside setBounds:CGRectMake(bounds.origin.x,
                                        bounds.origin.y,
                                        bounds.size.width,
                                        (bounds.size.height + [moleDictionary count] * 62))];
    }
    
    if (indexPath.row == 5)
    {
        DashboardMolyEstZone* cell = (DashboardMolyEstZone*)[_cellList objectAtIndex:indexPath.row];
        height = @(cell.bounds.size.height);
    }
    
    return [height floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
