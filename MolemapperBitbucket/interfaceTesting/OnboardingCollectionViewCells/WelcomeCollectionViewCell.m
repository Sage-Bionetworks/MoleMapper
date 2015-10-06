//
//  WelcomeCollectionViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "WelcomeCollectionViewCell.h"

@implementation WelcomeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)btnPressed:(UIButton *)sender
{
    [_parentViewController presentMailVC];
}



@end
