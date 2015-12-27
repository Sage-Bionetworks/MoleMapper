//
//  StatisticsTVC.m
//  MoleMapper
//
//  Created by Dan Webster on 12/9/13.
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


#import "StatisticsTVC.h"
#import "Zone.h"
#import "Zone+MakeAndMod.h"
#import "Mole.h"
#import "Mole+MakeAndMod.h"
#import "Measurement.h"
#import "Measurement+MakeAndMod.h"
#import "BodyMapViewController.h"
#import "ZoneViewController.h"
#import "MoleViewController.h"
#import "AppDelegate.h"

@interface StatisticsTVC ()

@property (nonatomic, weak) IBOutlet UITableViewCell *zonesDocumented;
@property (nonatomic, weak) IBOutlet UITableViewCell *totalMolesDocumented;
@property (nonatomic, weak) IBOutlet UITableViewCell *measurementsTaken;
@property (nonatomic, weak) IBOutlet UITableViewCell *averageMoleSize;
@property (nonatomic, weak) IBOutlet UITableViewCell *biggestMole;
@property (nonatomic, weak) IBOutlet UITableViewCell *moleyestZone;

@end

@implementation StatisticsTVC

#pragma mark - View Controller Life Cycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = ad.managedObjectContext;
    
    //To make rounded rect sections with spaces between, choose below
    //self.tableView.sectionHeaderHeight = 3.0;
    //self.tableView.sectionFooterHeight = 3.0;
    //self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.zonesDocumented.detailTextLabel.text = [self zonesDocumentedLabelString];
    self.totalMolesDocumented.detailTextLabel.text = [self numberOfMolesDocumented];
    self.measurementsTaken.detailTextLabel.text = [self numberOfMeasurementsDocumented];
    self.averageMoleSize.detailTextLabel.text = [self avgMoleSize];
    self.biggestMole.detailTextLabel.text = [self subtitleForBiggestMole];
    self.moleyestZone.detailTextLabel.text = [self subtitleForMolyestZone];
}


#pragma mark - Retrieving Data

-(NSString *)zonesDocumentedLabelString
{
    int numberOfZonesDocumented = 0;
    NSUInteger totalNumberOfZones = [[Zone allZoneIDs] count] - 2;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"zoneID" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (Zone *zone in matches)
    {
        //totalNumberOfZones++;
        if ([self imageFileExistsForZone:zone]) {numberOfZonesDocumented++;}
    }
    NSString *label = [NSString stringWithFormat:@"%d / %lu",numberOfZonesDocumented , (unsigned long)totalNumberOfZones];
    return label;
}

-(NSString *)numberOfMolesDocumented
{
    int numberOfMolesDocumented = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Mole" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    numberOfMolesDocumented = (int)[matches count];
    NSString *moleString = [NSString stringWithFormat:@"%d",numberOfMolesDocumented];
    return moleString;
}

-(NSString *)numberOfMeasurementsDocumented
{
    int numberOfMeasurementsDocumented = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    for (Measurement *measure in matches)
    {
        if ([measure.absoluteMoleDiameter doubleValue] > 0.0)
        {
            numberOfMeasurementsDocumented++;
        }
    }
    NSString *moleString = [NSString stringWithFormat:@"%d",numberOfMeasurementsDocumented];
    return moleString;
}

-(NSString *)avgMoleSize
{
    //Note: the proceeding comes from: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdFetching.html#//apple_ref/doc/uid/TP40002484-SW6
    
    float totalMoleSizes = 0.0;
    int totalValidMeasurements = 0;
    NSNumber *averageMoleSize = @0;
    NSString *averageMoleSizeString = @"N/A";
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.context];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&error];
    if (objects == nil) { } //Handle the error someday
    else
    {
        if ([objects count] > 0)
        {
            for (Measurement *meas in objects)
            {
                if ([meas.absoluteMoleDiameter doubleValue] > 0.0)
                {
                    totalMoleSizes += [meas.absoluteMoleDiameter floatValue];
                    totalValidMeasurements++;
                }
            }
            if (totalValidMeasurements > 0)
            {
                averageMoleSize = [NSNumber numberWithFloat:(totalMoleSizes / totalValidMeasurements)];
            }
        }
    }
    if (!totalMoleSizes == 0.0)
    {
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setMaximumFractionDigits:2];
        averageMoleSizeString = [fmt stringFromNumber:averageMoleSize];
        averageMoleSizeString = [averageMoleSizeString stringByAppendingString:@" mm"];
    }
    
    return averageMoleSizeString;
}

-(Measurement *)measurementForBiggestMole
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"absoluteMoleDiameter" ascending:YES]];
    
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:request error:&error];

    Measurement *measurementForBiggestMole = [matches lastObject];
    return measurementForBiggestMole;
}

-(NSString *)subtitleForBiggestMole
{
    Measurement *biggest = [self measurementForBiggestMole];
    NSString *subtitle = @"No moles measured yet";
    if (biggest.measurementID != nil)
    {
        NSString *moleName = biggest.whichMole.moleName;
        NSNumber *zoneID = @([biggest.whichMole.whichZone.zoneID intValue]);
        NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
        NSNumber *moleArea = biggest.absoluteMoleDiameter;
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setMaximumFractionDigits:2];
        NSString *moleAreaString = [fmt stringFromNumber:moleArea];
        NSString *measurement = [moleAreaString stringByAppendingString:@" mm"];
        subtitle = [NSString stringWithFormat:@"%@, %@, %@",moleName,zoneName,measurement];
    }
    return subtitle;
}

-(Zone *)zoneForMolyestZone
{
    Zone *molyestZone;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *matches = [self.context executeFetchRequest:fetchRequest error:&error];
    if ([matches count] == 0)
    {
        return nil;
    }
    else if ([matches count] == 1)
    {
        molyestZone = [matches lastObject];
    }
    else
    {
        int largestNumberOfMoles = 0;
        for (Zone *zone in matches)
        {
            NSSet *moles = zone.moles;
            int numberOfMoles = (int)[moles count];
            if (numberOfMoles > largestNumberOfMoles)
            {
                molyestZone = zone;
                largestNumberOfMoles = numberOfMoles;
            }
        }
    }
    return molyestZone;
}

-(NSString *)subtitleForMolyestZone
{
    Zone *zone = [self zoneForMolyestZone];
    NSString *subtitle = @"No moles added to a zone yet";
    if (zone)
    {
        NSNumber *zoneID = @([zone.zoneID intValue]);
        NSString *zoneName = [Zone zoneNameForZoneID:zoneID];
        int numberOfMolesInMolyestZone = (int)[zone.moles count];
        subtitle = [NSString stringWithFormat:@"%@, %@ moles",zoneName, @(numberOfMolesInMolyestZone)];
    }
    return subtitle;
}

#pragma mark - Table view data source

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    //[cell.layer setCornerRadius:15.0f];
    //[cell.layer setMasksToBounds:YES];
    //[cell.layer setBorderWidth:0.5f];
    //[cell.layer setBorderColor:[[UIColor grayColor] CGColor]];

    // Configure the cell...
    
    return cell;
}

#pragma mark - Random Helpers

//Helper method to check if file exists for a given zone
-(BOOL)imageFileExistsForZone:(Zone *)zone
{
    BOOL fileExists;
    NSString *zoneID = [NSString stringWithFormat:@"zone%@",zone.zoneID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filename = [zoneID stringByAppendingString:@".png"];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return fileExists;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"statsSegueToZoneView"])
    {
        if (![self zoneForMolyestZone]) {return NO;}
        else {return YES;}
    }
    else if ([identifier isEqualToString:@"statsSegueToMoleView"])
    {
        if (![self measurementForBiggestMole]) {return NO;}
        else {return YES;}
    }
    else {return YES;}
    
}
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Zone *zoneForSegue = [self zoneForMolyestZone];
    NSNumber *zoneID = @([zoneForSegue.zoneID intValue]);
    Measurement *measurementForSegue = [self measurementForBiggestMole];
    Mole *moleForSegue = measurementForSegue.whichMole;
    
    if ([segue.identifier isEqualToString:@"statsSegueToZoneView"])
    {
        ZoneViewController *destVC = segue.destinationViewController;
        
        destVC.zoneTitle = [Zone zoneNameForZoneID:zoneID];
        destVC.context = self.context;
        destVC.zoneID = zoneForSegue.zoneID; //zoneID is a 4-digit int as a string used as a key in Core Data
    }

    else if ([segue.identifier isEqualToString:@"statsSegueToMoleView"])
    {
        MoleViewController *destVC = segue.destinationViewController;
        destVC.mole = moleForSegue;
        destVC.moleID = moleForSegue.moleID;
        destVC.moleName = moleForSegue.moleName;
        destVC.context = self.context;
        destVC.zoneID = moleForSegue.whichZone.zoneID;
        
        NSNumber *zoneIDForSegue = @([moleForSegue.whichZone.zoneID intValue]);
        
        destVC.zoneTitle = [Zone zoneNameForZoneID:zoneIDForSegue];
        destVC.measurement = measurementForSegue;
    }
}


@end
