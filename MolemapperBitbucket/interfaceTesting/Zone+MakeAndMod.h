//
//  Zone+MakeAndMod.h
//  interfaceTesting
//
//  Created by Dan Webster on 7/13/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import "Zone.h"

@interface Zone (MakeAndMod)

//create a new Zone with provided parameters or fetch an existing zone
//Acts like a 'constructor' method
+ (Zone *)zoneForZoneID:(NSString *)zoneID
            withZonePhotoFileName:(NSString *)zonePhotoFileName
   inManagedObjectContext:(NSManagedObjectContext *)context;

+(NSArray *)allZoneIDs;

+(UIImage *)imageForZoneName:(NSString *)zoneName;

+(NSString *)zoneNameForZoneID:(NSNumber *)zoneID;

+(BOOL)hasValidImageDataForZoneID:(NSString *)zoneID;

//Prepends the current docs directory to the filename
+(NSString *)imageFullFilepathForZoneID:(NSString *)zoneID;

//formats the image as zoneZONEID.png
//Example: zone1100.png
+(NSString *)imageFilenameForZoneID:(NSString *)zoneID;

//+(NSString *)zoneNameForZoneID:(NSString *)zoneID;

//+(NSArray *)pointsForDrawingZoneForZoneID:(NSString *)zoneID;

@end
