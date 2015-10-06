//
//  InvolveCollectionViewCell.h
//  MoleMapper
//
//  Created by Karpács István on 05/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeCarouselViewController.h"

@interface InvolveCollectionViewCell : UICollectionViewCell

- (IBAction)showDetailText:(UIButton *)sender;

@property WelcomeCarouselViewController *parentViewController;

@end
