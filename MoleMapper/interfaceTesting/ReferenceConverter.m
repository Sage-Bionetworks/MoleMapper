//
//  ReferenceConverter.m
//  MoleMapper
//
//  Created by Dan Webster on 1/1/14.
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
