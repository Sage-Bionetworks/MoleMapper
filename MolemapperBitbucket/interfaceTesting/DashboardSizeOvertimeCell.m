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

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

@end
