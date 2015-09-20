//
//  DBSizeOverTimeCellTableViewCell.h
//  MoleMapper
//
//  Created by Karpács István on 18/09/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBSizeOverTimeCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *moleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moleSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moleProgressLabel;

@property NSDictionary* moleDictionary;
@property NSInteger idx;

@property NSNumber* lastProgress;

@end