//
//  Measurement.h
//  MoleMapper
//
//  Created by Dan Webster on 1/2/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Mole;

@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSNumber * absoluteMoleDiameter;
@property (nonatomic, retain) NSNumber * absoluteReferenceDiameter;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * measurementDiameter;
@property (nonatomic, retain) NSString * measurementID;
@property (nonatomic, retain) NSString * measurementPhoto;
@property (nonatomic, retain) NSNumber * measurementX;
@property (nonatomic, retain) NSNumber * measurementY;
@property (nonatomic, retain) NSNumber * referenceDiameter;
@property (nonatomic, retain) NSNumber * referenceX;
@property (nonatomic, retain) NSNumber * referenceY;
@property (nonatomic, retain) NSString * referenceObject;
@property (nonatomic, retain) Mole *whichMole;

@end
