//
//  WelcomeCarouselViewController.h
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
@import  MessageUI;

@interface WelcomeCarouselViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *onboardingCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControll;

@property NSMutableArray* cellContainer;

-(void)presentMailVC;

@end
