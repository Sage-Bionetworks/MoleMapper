//
//  DashboardSizeOvertimeCell.m
//  MoleMapper
//
//  Created by Karpács István on 17/09/15.
// Copyright (c) 2016, OHSU. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
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
    _header.backgroundColor = [[DashboardModel sharedInstance] getColorForHeader];
    _headerTitle.textColor = [[DashboardModel sharedInstance] getColorForDashboardTextAndButtons];
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
        cell.idx = indexPath.row;
    }
    
    return cell;
}

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
    
    moleViewController.isPresentView = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:moleViewController];
    [_dashBoardViewController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

@end
