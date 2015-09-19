//
//  DataExporter.h
//  MoleMapper
//
//  Created by Dan Webster on 6/20/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

//Class to get mole/measurement data and export to various server architectures (REDCap/Sage/etc)
#import <Foundation/Foundation.h>



@interface DataExporter : NSObject

@property NSManagedObjectContext *context;

-(void)postToRedCapWithFollowupData:(NSDictionary *)followupData;
-(void)postToRedCapWithInitialData:(NSDictionary *)initialData;
-(void)postToRedCapWithAllMoleData;
-(void)postToRedCapWithAllMeasurementData;

//Note to self: Consider implementing photo transfer only if Wifi connected
-(void)postToRedCapWithAllPhotoData;


@end
