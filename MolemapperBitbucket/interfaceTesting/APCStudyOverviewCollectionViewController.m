// 
//  APCStudyOverviewCollectionViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
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
 
#import "APCStudyOverviewCollectionViewController.h"
#import "APCWebViewController.h"
#import "APCLog.h"

#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

#import <ResearchKit/ResearchKit.h>

#import "AppDelegate.h"
#import "MMUser.h"
#import "OnboardingViewController.h"
#import <AFNetworkReachabilityManager.h>

static NSString *kConsentEmailSubject = @"Consent Document";

@interface APCStudyOverviewCollectionViewController () <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gradientCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnAlreadyParticipated;

@end

@implementation APCStudyOverviewCollectionViewController


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.items = [NSMutableArray new];
    
    [self setUpAppearance];
    self.items = [self prepareContent];
    [self setUpPageView];
    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)goBackToSignUpJoin:(NSNotification *)__unused notification {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UIColor *)appPrimaryColor
{
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

- (NSArray *)prepareContent
{
    //This will be hard-coded in instead of read in from JSON
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self studyDetailsFromJSONFile:@"StudyOverview"]];
    
    
    if (self.showConsentRow) {
        
        APCTableViewStudyDetailsItem *reviewConsentItem = [APCTableViewStudyDetailsItem new];
        reviewConsentItem.caption = NSLocalizedString(@"Review Consent", nil);
        reviewConsentItem.iconImage = [UIImage imageNamed:@"consent_icon"];
        reviewConsentItem.tintColor = [self appPrimaryColor];
        
        APCTableViewRow *rowItem = [APCTableViewRow new];
        rowItem.item = reviewConsentItem;
        rowItem.itemType = kAPCTableViewStudyItemTypeReviewConsent;
        
        APCTableViewSection *section = [items firstObject];
        NSMutableArray *rowItems = [NSMutableArray arrayWithArray:section.rows];
        [rowItems addObject:rowItem];
        section.rows = [NSArray arrayWithArray:rowItems];
    }
    
    return [NSArray arrayWithArray:items];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)setUpPageView
{
    APCTableViewSection *sectionItem = self.items.firstObject;
    self.pageControl.numberOfPages = sectionItem.rows.count;
}

- (void)setupCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.researchInstituteImageView setImage:[UIImage imageNamed:@"moleMapperLogo"]];
}

- (void)setUpAppearance
{
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor blackColor];
    self.diseaseNameLabel.adjustsFontSizeToFitWidth = YES;
    self.diseaseNameLabel.minimumScaleFactor = 0.5;
    
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];
    
    self.btnAlreadyParticipated.tintColor = [self appPrimaryColor];
}

- (MMUser *)user
{
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return ad.user;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) __unused collectionView
{
    return 1;
}

-(NSInteger) collectionView: (UICollectionView *) __unused collectionView
	 numberOfItemsInSection: (NSInteger) __unused section
{
    APCTableViewSection *sectionItem = self.items.firstObject;
    return sectionItem.rows.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    APCTableViewStudyDetailsItem *studyDetails = [self itemForIndexPath:indexPath];

    if (indexPath.row == 0) {
        APCStudyLandingCollectionViewCell *landingCell = (APCStudyLandingCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAPCStudyLandingCollectionViewCellIdentifier forIndexPath:indexPath];
        landingCell.delegate = self;
        landingCell.titleLabel.text = studyDetails.caption;
        landingCell.subTitleLabel.text = studyDetails.detailText;
        landingCell.readConsentButton.hidden = YES;
        landingCell.emailConsentButton.hidden = NO;
        
        if ([MFMailComposeViewController canSendMail]) {
            [landingCell.emailConsentButton setTitleColor:[self appPrimaryColor] forState:UIControlStateNormal];
            [landingCell.emailConsentButton setUserInteractionEnabled:YES];
        } else {
            [landingCell.emailConsentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [landingCell.emailConsentButton setUserInteractionEnabled:NO];
        }
        
        if (studyDetails.showsConsent) {
            landingCell.readConsentButton.hidden = NO;
        }
        cell = landingCell;
        
    }
    else
    {
        APCStudyOverviewCollectionViewCell *webViewCell = (APCStudyOverviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAPCStudyOverviewCollectionViewCellIdentifier forIndexPath:indexPath];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"helpOurResearch" ofType:@"htm"];
                              //NSAssert(filePath, @"Expecting file \"%@.html\" to be present in the \"HTMLContent\" directory, but didn't find it", studyDetails.detailText);
        NSURL *targetURL = [NSURL URLWithString:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webViewCell.webView loadRequest:request];
        
        cell = webViewCell;
    }
    
    return cell;
}

- (CGSize) collectionView: (UICollectionView *) __unused collectionView
				   layout: (UICollectionViewLayout*) __unused collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate methods

- (void) scrollViewDidEndDecelerating: (UIScrollView *) __unused scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = (self.collectionView.contentOffset.x + pageWidth / 2) / pageWidth;
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(nullable NSError *)__unused error
{
    if (reason == ORKTaskViewControllerFinishReasonCompleted)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Public methods

- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName
{
    
    NSMutableArray *items = [NSMutableArray new];
    
    self.diseaseNameLabel.text = @"Mole Mapper";
    
    NSMutableArray *rowItems = [NSMutableArray new];
    
    APCTableViewStudyDetailsItem *studyDetails = [APCTableViewStudyDetailsItem new];
    
    
    studyDetails.caption = @"Welcome to Mole Mapper";
    studyDetails.detailText = @"\nThis app is a personalized tool that helps you track your moles over time and participate in a research study to better understand skin health and melanoma risks";
            //studyDetails.iconImage = [UIImage imageNamed:@"moleMapperIconSmall"];
            //studyDetails.iconImage = [[UIImage imageNamed:@"moleMapperIconSmall"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    studyDetails.tintColor = [self appPrimaryColor];
            //studyDetails.videoName = questionDict[@"video_name"];
            //studyDetails.showsConsent = ((NSString *)questionDict[@"show_consent"]).length > 0;
    
         
    APCTableViewRow *row = [APCTableViewRow new];
    row.item = studyDetails;
    row.itemType = kAPCTableViewStudyItemTypeStudyDetails;
    [rowItems addObject:row];
        
    APCTableViewSection *section = [APCTableViewSection new];
    section.rows = [NSArray arrayWithArray:rowItems];
    [items addObject:section];
    
    return [NSArray arrayWithArray:items];
}


- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyDetailsItem *studyDetailsItem = (APCTableViewStudyDetailsItem *)rowItem.item;
    
    return studyDetailsItem;
}

- (APCTableViewStudyItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyItemType studyItemType = rowItem.itemType;
    
    return studyItemType;
}

- (IBAction)pageClicked:(UIPageControl *)sender {
    NSInteger page = sender.currentPage;
    CGRect frame = self.collectionView.frame;
    CGFloat offset = frame.size.width * page;
    [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate method

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
            APCLogError2(error);
            break;
        default:
            break;
    }
    controller.mailComposeDelegate = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)studyLandingCollectionViewCellEmailConsent:(APCStudyLandingCollectionViewCell *) __unused cell
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
        mailComposeVC.mailComposeDelegate = self;
        
        [mailComposeVC addAttachmentData:[self PDFDataOfConsent] mimeType:@"application/pdf" fileName:@"Consent"];
        [mailComposeVC setSubject:kConsentEmailSubject];
        [self presentViewController:mailComposeVC animated:YES completion:NULL];
    }
}

#pragma mark - Utilities

- (NSData *)PDFDataOfConsent
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"consent" ofType:@"pdf"];
    NSAssert(filePath, @"Must include the consent PDF with filename \"consent.pdf\" in the app bundle");
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSAssert(fileData, @"Failed to create an NSData representation of \"consent.pdf\"");
    return fileData;
}

- (IBAction)joinStudyTapped:(id)sender
{
    //OnboardingViewController *onboarding = [[UIStoryboard storyboardWithName:@"onboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"onboardingBase"];
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        
    }
    else
    {
        
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:@"shouldShowEligibilityTest"];
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [ad showOnboarding];
    
}

- (IBAction)notReadyToJoinTapped:(id)sender
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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

@end
