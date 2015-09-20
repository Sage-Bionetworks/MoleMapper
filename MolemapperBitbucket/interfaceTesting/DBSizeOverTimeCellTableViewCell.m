//
//  DBSizeOverTimeCellTableViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "DBSizeOverTimeCellTableViewCell.h"
#import "DashboardModel.h"

@implementation DBSizeOverTimeCellTableViewCell

- (void)viewDidLoad {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    NSString *key = [NSString stringWithFormat:@"%i",  (int)_idx];
    NSDictionary *mole = [_moleDictionary objectForKey:key];
    
    _moleNameLabel.text = [mole objectForKey:@"name"];
    NSNumber* size = [mole objectForKey:@"size"];
    NSNumber* percentChange = [mole objectForKey:@"percentChange"];
    
    _moleSizeLabel.text = [NSString stringWithFormat:@"%2.1f%% mm", [size floatValue]];
    _moleProgressLabel.text = [NSString stringWithFormat:@"%2.1f%%", [percentChange floatValue]];
    
    // Configure the view for the selected state
}

@end
