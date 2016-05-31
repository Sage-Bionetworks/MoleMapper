//
//  WelcomeCarouselViewController.m
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
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


#import "WelcomeCarouselViewController.h"
#import "WelcomeCollectionViewCell.h"
#import "HelpCollectionViewCell.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "InvolveCollectionViewCell.h"
#import "APCButton.h"

@interface WelcomeCarouselViewController ()

@property (weak, nonatomic) IBOutlet APCButton *joinStudyButton;

#define NAME_OF_CONSENT_FORM @"consentForm_16038_2016_05_27"

@end

@implementation WelcomeCarouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellContainer = [[NSMutableArray alloc] init];
    
    self.joinStudyButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.joinStudyButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    //_cellContainer
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    [self.onboardingCollectionView setPagingEnabled:YES];
    
    UINib *nib1 = [UINib nibWithNibName:@"WelcomeCollectionViewCell" bundle:nil];
    [_onboardingCollectionView registerNib:nib1 forCellWithReuseIdentifier:@"WelcomeCollectionViewCell"];
    
    UINib *nib2 = [UINib nibWithNibName:@"HelpCollectionViewCell" bundle:nil];
    [_onboardingCollectionView registerNib:nib2 forCellWithReuseIdentifier:@"HelpCollectionViewCell"];
    
    //InvolveCollectionViewCell
    UINib *nib3 = [UINib nibWithNibName:@"InvolveCollectionViewCell" bundle:nil];
    [_onboardingCollectionView registerNib:nib3 forCellWithReuseIdentifier:@"InvolveCollectionViewCell"];
}

-(void)setupCollectionViewCells
{
   
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        WelcomeCollectionViewCell *cell = (WelcomeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WelcomeCollectionViewCell" forIndexPath:indexPath];
        cell.parentViewController = self;
        return cell;
    }
    
    if (indexPath.row == 1)
    {
        HelpCollectionViewCell *cell = (HelpCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HelpCollectionViewCell" forIndexPath:indexPath];
        return cell;
    }
    
    if (indexPath.row == 2)
    {
        InvolveCollectionViewCell *cell = (InvolveCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"InvolveCollectionViewCell" forIndexPath:indexPath];
        cell.parentViewController = self;
        return cell;
    }
    
    return nil;
}

- (CGSize) collectionView: (UICollectionView *) __unused collectionView layout: (UICollectionViewLayout*) __unused collectionViewLayout sizeForItemAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return collectionView.bounds.size;
}

- (NSInteger)horizontalPageNumber:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGSize viewSize = scrollView.bounds.size;
    
    NSInteger horizontalPage = MAX(0.0, contentOffset.x / viewSize.width);
    return horizontalPage;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControll.currentPage = [self horizontalPageNumber:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) _pageControll.currentPage = [self horizontalPageNumber:scrollView];
}

- (IBAction)joinStudyTapped:(id)sender
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        //check for isReachable here
        if ([[AFNetworkReachabilityManager sharedManager] isReachable])
        {
            NSLog(@"Is reachable");
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setBool:YES forKey:@"shouldShowEligibilityTest"];
            [ud setBool:NO forKey:@"shouldShowWelcomeScreenWithCarousel"];
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ad showOnboarding];
        }
        else
        {
            NSLog(@"Is not reachable");
            [self noInternetConnectivityAlertAndGoToBodyMap];
        }
    }];
}

-(void)noInternetConnectivityAlertAndGoToBodyMap
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"Internet Unavailable" message:@"You need to access the internet to register for this study. You can come back to the study enrollment process at any time by tapping the Beaker icon at the top of the Body Map. Your progress has been saved." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Go to Body Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"User has left the onboarding process with cancel");
        [ad showBodyMap];
    }];
    
    /*
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [ud setBool:YES forKey:@"shouldShowWelcomeCarousel"];
        [ud setBool:NO forKey:@"shouldShowEligibilityTest"];
        [ad showWelcomeScreenWithCarousel];
    }];
     */
    
    [leaveOnboarding addAction:leave];
    //[leaveOnboarding addAction:cancel];
    
    [self presentViewController:leaveOnboarding animated:YES completion:nil];
    
}


- (IBAction)notReadyToJoinTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"Go to Body Map" message:@"You can come back to the study enrollment process at any time by tapping the Beaker icon at the top of the Body Map. Your progress has been saved." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *leave = [UIAlertAction actionWithTitle:@"Go to Body Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"User has left the onboarding process with cancel");
        [ad showBodyMap];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    
    [leaveOnboarding addAction:leave];
    [leaveOnboarding addAction:cancel];
    
    [self presentViewController:leaveOnboarding animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    //controller.mailComposeDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)presentMailVC
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    if (mc)
    {
        mc.mailComposeDelegate = self;
        [mc setSubject:@"Study Consent Document"];
        [mc setMessageBody:@"" isHTML:NO];
        [mc setToRecipients:@[@""]];
        
        NSString *pdfPath = [[NSBundle mainBundle] pathForResource:NAME_OF_CONSENT_FORM ofType:@"pdf"];
        NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
        [mc addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"Consent Document.pdf"];

        [self presentViewController:mc animated:YES completion:NULL];
    }
}

@end
