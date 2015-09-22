//
//  ComparisonPageViewController.m
//  MoleMapper
//
//  Created by Dan Webster on 10/29/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "ComparisonPageViewController.h"
#import "MeasurementComparsionViewController.h"
#import "Measurement+MakeAndMod.h"
#import "Measurement.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"

@interface ComparisonPageViewController ()

@end

@implementation ComparisonPageViewController

-(NSMutableArray *)moleMeasurements
{
    if (!_moleMeasurements)
    {
        _moleMeasurements = [[NSMutableArray alloc] init];
    }
    return _moleMeasurements;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getMoleMeasurementsFromCoreData];
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showEmail:)];
    self.navigationItem.rightBarButtonItem = exportButton;
    
	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    MeasurementComparsionViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
}

-(void)getMoleMeasurementsFromCoreData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    NSSortDescriptor *sortMeasurementsByDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    sortMeasurementsByDate = [sortMeasurementsByDate reversedSortDescriptor];
    request.sortDescriptors = @[sortMeasurementsByDate];
    request.predicate = [NSPredicate predicateWithFormat:@"whichMole = %@", self.mole];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];
    [self.moleMeasurements addObjectsFromArray:matches];

}

- (MeasurementComparsionViewController *)viewControllerAtIndex:(int)index {
    
    Measurement *moleMeasurement = (Measurement *)self.moleMeasurements[index];
    MeasurementComparsionViewController *childViewController = [[MeasurementComparsionViewController alloc] init];
    
    childViewController.moleMeasurement = moleMeasurement;
    childViewController.index = index;
    
    return childViewController;
    
}

//helpful site here: http://www.appcoda.com/uipageviewcontroller-tutorial-intro/

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int index = [(MeasurementComparsionViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int index = [(MeasurementComparsionViewController *)viewController index];
    
    index++;
    
    if (index == self.moleMeasurements.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return self.moleMeasurements.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator, defaulted to the first mole measurement (sorted by most recent date).
    return 0;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - MFMailComposeViewController Delegate Methods
//Notes for this implementation found here: http://www.appcoda.com/ios-programming-101-send-email-iphone-app/

- (IBAction)showEmail:(id)sender
{
    MeasurementComparsionViewController *currentMeasurement = [self.pageController.viewControllers firstObject];
    NSString *emailTitle = [self emailTitleForMeasurement:currentMeasurement.moleMeasurement];
    NSString *messageBody = [self emailBodyForMeasurement:currentMeasurement.moleMeasurement];
    NSArray *toRecipents = [NSArray arrayWithObject:[self recipientForEmail]];
    NSString *filePath = currentMeasurement.moleMeasurement.measurementID;
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *mimeType = @"image/png";
    NSString *fileName = @"filename";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    [mc addAttachmentData:fileData mimeType:mimeType fileName:fileName];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

-(NSString *)emailTitleForMeasurement:(Measurement *)measurement
{
    NSString *title = [NSString stringWithFormat:@"[Mole Mapper] %@",measurement.whichMole.moleName];
    return title;
}

-(NSString *)emailBodyForMeasurement:(Measurement *)measurement
{
    NSString *moleData = [NSString stringWithFormat:@"Mole Name: %@\n",measurement.whichMole.moleName];
    NSNumber *zoneID = @([measurement.whichMole.whichZone.zoneID intValue]);
    NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
    NSString *zoneData = [NSString stringWithFormat:@"Body Map Zone: %@\n",zoneName];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSString *stringFromDate = [formatter stringFromDate:measurement.date];
    stringFromDate = [stringFromDate stringByAppendingString:@": "];
    //ceilf(initialDiameter * 10.0f) / 10.0f;
    NSString* formattedSize = [NSString stringWithFormat:@"%.1f", ceilf([measurement.absoluteMoleDiameter floatValue] * 10.0f) / 10.0f];
    stringFromDate = [stringFromDate stringByAppendingString:formattedSize];
    stringFromDate = [stringFromDate stringByAppendingString:@" mm\n"];
    
    NSString *attachmentNotice = [NSString stringWithFormat:@"\n[Photo Attached]\n\n"];
    //NSString *postScript = @"To auto-populate these emails with your email address, please go to Settings in the Menu screen.\n";
    NSString *body = [NSString stringWithFormat:@"%@%@%@%@",moleData,zoneData,stringFromDate,attachmentNotice];//,postScript];
    return body;
}

-(NSString *)recipientForEmail
{
    NSString *emailRecipient = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *recipientFromUserDefaults = [standardUserDefaults valueForKey:@"emailForExport"];
    if (recipientFromUserDefaults) {emailRecipient = recipientFromUserDefaults;}
    return emailRecipient;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
