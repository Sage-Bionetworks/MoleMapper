//
//  MoleNameGenerator.h
//  interfaceTesting
//
//  Created by Dan Webster on 7/16/13.
//  Copyright (c) 2013 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoleNameGenerator : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

-(NSString *)randomUniqueMoleNameWithGenderSpecification:(NSString *)gender;

@end
