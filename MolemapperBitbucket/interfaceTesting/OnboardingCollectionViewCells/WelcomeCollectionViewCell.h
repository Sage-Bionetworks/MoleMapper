//
//  WelcomeCollectionViewCell.h
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeCarouselViewController.h"
@import MessageUI;

@interface WelcomeCollectionViewCell : UICollectionViewCell <MFMailComposeViewControllerDelegate>

@property WelcomeCarouselViewController* parentViewController;
- (IBAction)btnPressed:(UIButton *)sender;

@end
