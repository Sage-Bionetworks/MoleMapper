//
//  WelcomeCarouselViewController.m
//  MoleMapper
//
//  Created by Karpács István on 04/10/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import "WelcomeCarouselViewController.h"
#import "WelcomeCollectionViewCell.h"
#import "HelpCollectionViewCell.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "InvolveCollectionViewCell.h"

@interface WelcomeCarouselViewController ()

@end

@implementation WelcomeCarouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellContainer = [[NSMutableArray alloc] init];
    
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
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ad showOnboarding];
        }
        else
        {
            NSLog(@"Is not reachable");
        }
    }];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:@"shouldShowEligibilityTest"];
    [ud setBool:NO forKey:@"shouldShowWelcomeCarousel"];
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding];
}

- (IBAction)notReadyToJoinTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    UIAlertController *leaveOnboarding = [UIAlertController alertControllerWithTitle:@"Go to Body Map" message:@"You can come back to the study enrollment process at any time by visiting the Profile tab" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
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
        [mc setSubject:@"Mole Mapper Conset"];
        [mc setMessageBody:@"" isHTML:NO];
        [mc setToRecipients:@[@""]];
        //[mc addAttachmentData:fileData mimeType:mimeType fileName:fileName];

        [self presentViewController:mc animated:YES completion:NULL];
    }
    
    /*[mailComposeVC addAttachmentData:[self PDFDataOfConsent] mimeType:@"application/pdf" fileName:@"Consent"];
     [mailComposeVC setSubject:kConsentEmailSubject];*/
    
}

@end
