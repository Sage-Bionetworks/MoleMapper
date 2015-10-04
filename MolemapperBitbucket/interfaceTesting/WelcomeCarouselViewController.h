//
//  WelcomeCarouselViewController.h
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeCarouselViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *onboardingCollectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControll;

@property NSMutableArray* cellContainer;

@end
