//
//  ReferenceConverter.h
//  MoleMapper
//
//  Created by Dan Webster on 1/1/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

//Will take strings from the reference field and convert to an absolute diameter (NSNumber in millimeters)
@interface ReferenceConverter : NSObject

@property (strong, nonatomic) NSDictionary *refToDiameter;


//Will check if input is a valid pre-defined reference (i.e. U.S. Dime)
//Will check if custom input number is non-zero and positive
-(BOOL)isAValidReference:(NSString *)reference;

//Will return nil if not a valid reference input (uses public method above)
-(NSNumber *)millimeterValueForReference:(NSString *)reference;

@end
