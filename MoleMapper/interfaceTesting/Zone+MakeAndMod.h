//
//  Zone+MakeAndMod.h
//  interfaceTesting
//
//  Created by Dan Webster on 7/13/13.
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

+(void)deleteAllMolesInZone:(Zone *)zone inManagedObjectContext:(NSManagedObjectContext *)context;

//+(NSString *)zoneNameForZoneID:(NSString *)zoneID;

//+(NSArray *)pointsForDrawingZoneForZoneID:(NSString *)zoneID;

@end
