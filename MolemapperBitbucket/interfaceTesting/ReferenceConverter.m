//
//  ReferenceConverter.m
//  MoleMapper
//
//  Created by Dan Webster on 1/1/14.
//  Copyright (c) 2014 Webster Apps. All rights reserved.
//

#import "ReferenceConverter.h"

@implementation ReferenceConverter

-(NSDictionary *)refToDiameter
{
    if (!_refToDiameter)
    {
        _refToDiameter = @{
        @"Penny"   : @19.05,
        @"Nickel"  : @21.21,
        @"Dime"    : @17.91,
        @"Quarter" : @24.26,
                          };
    }
    return _refToDiameter;
}

-(NSNumber *)millimeterValueForReference:(NSString *)reference
{
    NSNumber *refValue = nil;
    reference = [reference stringByReplacingOccurrencesOfString:@"Reference: " withString:@""];
    if ([self isAValidReference:reference])
    {
        //if exists in the pre-defined dictionary of values
        if ([self.refToDiameter objectForKey:reference])
        {
            refValue = [self.refToDiameter objectForKey:reference];
        }
        else if ([self contains:@"mm" within:reference])
        {
            float refMM = [self parseFloatFromCustomReferenceString:reference];
            refValue = [NSNumber numberWithFloat:refMM];
        }
    }
    return refValue;
}

-(BOOL)isAValidReference:(NSString *)reference
{
    BOOL referenceIsValid = NO;
    
    //If the reference value is in the pre-defined set, then it is valid
    if ([self.refToDiameter objectForKey:reference] != nil) {referenceIsValid = YES;}
    
    //A custom input reference will end up with this format: @"VALUE mm (custom)", parse and check for non-negative, non-zero number
    else if ([self contains:@"mm" within:reference])
    {
        //Parse out the number value within this string
        float refMM = [self parseFloatFromCustomReferenceString:reference];
        if (refMM > 0) {referenceIsValid = YES;}
    }
    return referenceIsValid;
}

//Helper function adapted from here: http://stackoverflow.com/questions/2753956/string-contains-string-in-objective-c
-(BOOL)contains:(NSString *)StrSearchTerm within:(NSString *)StrText
{
    return  [StrText rangeOfString:StrSearchTerm options:NSCaseInsensitiveSearch].location==NSNotFound?FALSE:TRUE;
}

-(float)parseFloatFromCustomReferenceString:(NSString *)reference
{
    NSArray *refStringComponents = [reference componentsSeparatedByString:@" "];
    NSString *referenceMM = [refStringComponents objectAtIndex:0];
    float refMM = [referenceMM floatValue];
    return refMM;
}

@end
