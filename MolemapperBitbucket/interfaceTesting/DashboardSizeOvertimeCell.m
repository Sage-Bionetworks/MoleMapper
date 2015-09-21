//
//  DashboardSizeOvertimeCell.m
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DashboardSizeOvertimeCell.h"
#import "DBSizeOverTimeCellTableViewCell.h"
#import "DashboardModel.h"
#import "MoleViewController.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import "AppDelegate.h"

@implementation DashboardSizeOvertimeCell

@synthesize tableViewInside;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_allMolesDicitionary count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"DBSizeOverTimeCellTableViewCell";
    
    DBSizeOverTimeCellTableViewCell *cell = (DBSizeOverTimeCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DBSizeOverTimeCellTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.moleDictionary = _allMolesDicitionary;
        
        cell.idx = ([_allMolesDicitionary count] - 1) - indexPath.row;
    }
    
    return cell;
}

/*-(NSDictionary*) getPercentChangeByIndex:(NSInteger) index
{
    /*for (int i = 0; i < [_allMolesDicitionary count]; ++i)
    {
        [_allMolesDicitionary ]
    }
    
    return nil;
}*/


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    MoleViewController *moleViewController = (MoleViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MoleViewController"];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[DBSizeOverTimeCellTableViewCell class]]) {
        
        NSString* idx = [NSString stringWithFormat:@"%i", (int)((DBSizeOverTimeCellTableViewCell*)cell).idx];
        NSDictionary* mole = [_allMolesDicitionary objectForKey:idx];
        
        Measurement *measurement = [mole objectForKey:@"measurement"];
        moleViewController.mole = measurement.whichMole;
        moleViewController.moleID = measurement.whichMole.moleID;
        moleViewController.moleName = [mole objectForKey:@"name"];
        moleViewController.context = _dashBoardViewController.context;
        moleViewController.zoneID = measurement.whichMole.whichZone.zoneID;
        
        NSNumber *zoneIDForSegue = @([measurement.whichMole.whichZone.zoneID intValue]);
        
        moleViewController.zoneTitle = [Zone zoneNameForZoneID:zoneIDForSegue];
        moleViewController.measurement = measurement;

    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:moleViewController];
    [_dashBoardViewController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

@end
