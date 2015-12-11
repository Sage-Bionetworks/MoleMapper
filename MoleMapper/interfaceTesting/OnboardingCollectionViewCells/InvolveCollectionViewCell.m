//
//  InvolveCollectionViewCell.m
//  MoleMapper
//
//  Created by Karpács István on 05/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "InvolveCollectionViewCell.h"
#import "DetailTextViewController.h"

@implementation InvolveCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)showDetailText:(UIButton *)sender
{
    DetailTextViewController *detail = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailTextViewController"];
    
    [self.parentViewController presentViewController:detail animated:YES completion:nil];
}
@end
