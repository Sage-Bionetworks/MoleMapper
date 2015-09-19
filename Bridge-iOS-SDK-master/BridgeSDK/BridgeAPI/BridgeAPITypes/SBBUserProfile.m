//
//  SBBUserProfile.m
//
//	Copyright (c) 2014, Sage Bionetworks
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	    * Redistributions of source code must retain the above copyright
//	      notice, this list of conditions and the following disclaimer.
//	    * Redistributions in binary form must reproduce the above copyright
//	      notice, this list of conditions and the following disclaimer in the
//	      documentation and/or other materials provided with the distribution.
//	    * Neither the name of Sage Bionetworks nor the names of BridgeSDk's
//		  contributors may be used to endorse or promote products derived from
//		  this software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBBUserProfile.h"
@import ObjectiveC;

@implementation SBBUserProfile

#pragma mark Abstract method overrides

// Custom logic goes here.

// Check that the selector corresponds to a property.
// Note that this doesn't handle custom getter/setter names in the declaration.
+ (objc_property_t)propertyFromSelector:(SEL)sel
{
    NSString *propertyName = NSStringFromSelector(sel);
    objc_property_t property = NULL;
    if ([propertyName hasSuffix:@":"]) {
        // setter--assume sel is of the form 'setXxxXxx:' where the property name is 'XxxXxx' or 'xxxXxx'
        // - cut off the trailing ':'
        propertyName = [[propertyName substringToIndex:propertyName.length - 1] substringFromIndex:3];
        property = class_getProperty([self class], [propertyName UTF8String]);
        if (property == NULL) {
            // dromedary-camelCase the string and try again
            propertyName = [[[propertyName substringToIndex:1] lowercaseString] stringByAppendingString:[propertyName substringFromIndex:1]];
            property = class_getProperty([self class], [propertyName UTF8String]);
        }
    } else {
        // getter--assume selector is property name
        property = class_getProperty([self class], [propertyName UTF8String]);
    }

    return property;
}

static NSString *nameForProperty(objc_property_t property)
{
    return [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
}

static void dynamicSetterIMP(id self, SEL _cmd, id value)
{
    objc_property_t property = [[self class] propertyFromSelector:_cmd];
    if (value) {
        [[self customFields] setObject:value forKey:nameForProperty(property)];
    } else {
        [[self customFields] removeObjectForKey:nameForProperty(property)];
    }
}

static NSString *dynamicGetterIMP(id self, SEL _cmd)
{
    objc_property_t property = [[self class] propertyFromSelector:_cmd];
    return [[self customFields] objectForKey:nameForProperty(property)];
}

// Create the custom fields container on demand.
// Note: it's an associated object and not just a property because we don't want to include it when serializing the object to JSON.
- (NSMutableDictionary *)customFields
{
    NSMutableDictionary *customFields = objc_getAssociatedObject(self, @selector(customFields));
    if (!customFields) {
        customFields = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(customFields), customFields, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return customFields;
}


// This is called by the Objective-C runtime when the object receives a message on a selector it doesn't implement.
// We're going to take advantage of that to provide setter and getter implementations for @dynamic properties
// declared in categories of SBBUserProfile, so that all the existing machinery around marshaling and serializing
// objects to/from Bridge JSON will just work.
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    BOOL isSetter = [NSStringFromSelector(sel) hasSuffix:@":"];
    objc_property_t property = [self propertyFromSelector:sel];
    if (property) {
        if (isSetter) {
            // set the IMP for sel to dynamicSetterIMP
            class_addMethod(self, sel, (IMP)dynamicSetterIMP, "v@:@");
        } else {
            // set the IMP for sel to dynamicGetterIMP
            class_addMethod(self, sel, (IMP)dynamicGetterIMP, "@@:");
        }
    }
    
    return [super resolveInstanceMethod:sel];
}

@end
