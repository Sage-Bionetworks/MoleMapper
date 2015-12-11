//
//  Zone+MakeAndMod.m
//  interfaceTesting
//
//  Created by Dan Webster on 7/13/13.
//  CopyRight (c) 2013 Webster Apps. All Rights reserved.
//

#import "Zone+MakeAndMod.h"
#import "AppDelegate.h"
#import "Mole.h"

@implementation Zone (MakeAndMod)

+(NSArray *)allZoneIDs
{
    return @[@"1100",
             @"1200",
             @"1250",
             @"1251",
             @"1300",
             @"1301",
             @"1350",
             @"1351",
             @"1400",
             @"1401",
             @"1450",
             @"1451",
             @"1500",
             @"1501",
             @"1550",
             @"1551",
             @"1600",
             @"1601",
             @"1650",
             @"1651",
             @"1700",
             @"1701",
             @"1750",
             @"1751",
             @"1800",
             @"1801",
             @"1850",
             @"1851",
             @"2100",
             @"2200",
             @"2250",
             @"2251",
             @"2300",
             @"2301",
             @"2350",
             @"2351",
             @"2400",
             @"2401",
             @"2450",
             @"2451",
             @"2500",
             @"2501",
             @"2550",
             @"2551",
             @"2600",
             @"2601",
             @"2650",
             @"2651",
             @"2700",
             @"2701",
             @"2750",
             @"2751",
             @"2800",
             @"2801",
             @"2850",
             @"2851",
             @"3150",
             @"3151",
             @"3170",
             @"3171",
             @"3172"];
}

//create a new Zone with provided parameters or fetch an existing zone
//Acts like a 'constructor' method
+ (Zone *)zoneForZoneID:(NSString *)zoneID
          withZonePhotoFileName:(NSString *)zonePhotoFileName
 inManagedObjectContext:(NSManagedObjectContext *)context;
{
    Zone *zone = nil;
    
    //This fetch request is formatted following the example here: http://www.raywenderlich.com/999/core-data-tutorial-how-to-use-nsfetchedresultscontroller
    //The rest is formatted from Paul Hegarty's lecture demo on Photomania
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Zone" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"zoneID" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"zoneID = %@", zoneID];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!matches)
    {
        //NSLog(@"Couldn't fetch any matches from zoneForZoneName...");
    }
    else if ([matches count] > 1)
    {
        //NSLog(@"Pulled out more than 1 match for zoneName: %@",zoneID);
    }
    else if ([matches count] == 0)
    {
        zone = [NSEntityDescription insertNewObjectForEntityForName:@"Zone"
                                             inManagedObjectContext:context];
        
        zone.zoneID = zoneID;
        zone.zonePhoto = zonePhotoFileName;
    }
    
    else
    {
        zone = [matches lastObject];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
    return zone;
 
}

+(void)deleteAllMolesInZone:(Zone *)zone inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mole"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"moleID" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"whichZone.zoneID = %@", zone.zoneID];
    NSError *error = nil;
    
    NSArray *molesInProvidedZone = [context executeFetchRequest:request error:&error];
    for (Mole *mole in molesInProvidedZone)
    {
        [context deleteObject:mole];
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

+ (UIImage *)imageForZoneName:(NSString *)zoneName
{
    UIImage *image = nil;
    NSString *filePath = [Zone imageFullFilepathForZoneID:zoneName];
    //NSLog(@"Fetched filePath is %@",filePath);
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    //NSString *imageName = [zoneName stringByAppendingString:@".png"];
    //NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    image = [UIImage imageWithData:pngData];
    return image;
}

+ (NSString *)imageFullFilepathForZoneID:(NSString *)zoneID
{
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [NSString stringWithFormat:@"%@/zone%@.png",docsDirectory,zoneID];
}

+(NSString *)imageFilenameForZoneID:(NSString *)zoneID
{
    NSString *fileName = [NSString stringWithFormat:@"zone%@.png",zoneID];
    return fileName;
}

+(BOOL)hasValidImageDataForZoneID:(NSString *)zoneID
{
    BOOL hasValidImageData = YES;
    if (!zoneID) {hasValidImageData = NO;}
    UIImage *zoneImage = [Zone imageForZoneName:zoneID];
    if (!zoneImage) {hasValidImageData = NO;}
    CGImageRef cgref = [zoneImage CGImage];
    CIImage *cim = [zoneImage CIImage];
    if (cim == nil && cgref == NULL)
    {
        hasValidImageData = NO;
    }
    return hasValidImageData;
}

+ (NSString *)zoneNameForZoneID:(NSNumber *)zoneID
{
    NSDictionary *zoneNameToZoneID =
    @{
      @1100 : @"Head",
      @1200 : @"Neck & Center Chest",
      @1250 : @"Right Pectoral",
      @1251 : @"Left Pectoral",
      @1300 : @"Right Abdomen",
      @1301 : @"Left Abdomen",
      @1350 : @"Right Pelvis",
      @1351 : @"Left Pelvis",
      @1400 : @"Right Upper Thigh",
      @1401 : @"Left Upper Thigh",
      @1450 : @"Right Lower Thigh & Knee",
      @1451 : @"Left Lower Thigh & Knee",
      @1500 : @"Right Upper Calf",
      @1501 : @"Left Upper Calf",
      @1550 : @"Right Lower Calf",
      @1551 : @"Left Lower Calf",
      @1600 : @"Right Ankle & Foot",
      @1601 : @"Left Ankle & Foot",
      @1650 : @"Right Shoulder",
      @1651 : @"Left Shoulder",
      @1700 : @"Right Upper Arm",
      @1701 : @"Left Upper Arm",
      @1750 : @"Right Upper Forearm",
      @1751 : @"Left Upper Forearm",
      @1800 : @"Right Lower Forearm",
      @1801 : @"Left Lower Forearm",
      @1850 : @"Right Hand",
      @1851 : @"Left Hand",
      @2100 : @"Head",
      @2200 : @"Neck",
      @2250 : @"Left Upper Back",
      @2251 : @"Right Upper Back",
      @2300 : @"Left Lower Back",
      @2301 : @"Right Lower Back",
      @2350 : @"Left Glute",
      @2351 : @"Right Glute",
      @2400 : @"Left Upper Thigh",
      @2401 : @"Right Upper Thigh",
      @2450 : @"Left Lower Thigh & Knee",
      @2451 : @"Right Lower Thigh & Knee",
      @2500 : @"Left Upper Calf",
      @2501 : @"Right Upper Calf",
      @2550 : @"Left Lower Calf",
      @2551 : @"Right Lower Calf",
      @2600 : @"Left Ankle & Foot",
      @2601 : @"Right Ankle & Foot",
      @2650 : @"Left Shoulder",
      @2651 : @"Right Shoulder",
      @2700 : @"Left Upper Arm",
      @2701 : @"Right Upper Arm",
      @2750 : @"Left Elbow",
      @2751 : @"Right Elbow",
      @2800 : @"Left Lower Forearm",
      @2801 : @"Right Lower Forearm",
      @2850 : @"Left Hand",
      @2851 : @"Right Hand",
      @3150 : @"Face: Left Side",
      @3151 : @"Face: Right Side",
      @3170 : @"Top of Head",
      @3171 : @"Face: Front",
      @3172 : @"Back of Head",
      };
    
    return [zoneNameToZoneID objectForKey:zoneID];
}

@end
