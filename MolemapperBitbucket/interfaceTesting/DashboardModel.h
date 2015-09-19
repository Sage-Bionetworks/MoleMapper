//
//  DashboardModel.h
//  MoleMapper
//
//  Created by Andy Yeung on 9/12/15.
//  Copyright © 2015 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DashboardModel : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

+ (id)sharedInstance;
-(NSNumber *)daysSinceLastFollowup;
-(NSDictionary *)zoneNameToNumberOfMolesInZoneDictionary;
-(NSNumber *)numberOfZonesDocumented;
-(NSArray *)allMoleMeasurements;
-(NSString *)nameForBiggestMole;
-(NSString *)zoneNameForBiggestMole;
-(NSNumber *)sizeOfBiggestMole;
-(NSNumber *)sizeOfAverageMole;
-(NSMutableDictionary*) rankedListOfMoleSizeChangeAndMetadata;

@end
