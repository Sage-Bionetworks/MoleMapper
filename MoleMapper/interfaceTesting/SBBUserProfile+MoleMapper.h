//
//  SBBUserProfile+MoleMapper.h
//  MoleMapper
//
//  Created by Dan Webster on 9/11/15.
//  Copyright (c) 2015 Webster Apps. All rights reserved.
//

#import <BridgeSDK/BridgeSDK.h>

@interface SBBUserProfile (MoleMapper)

@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSString *melanomaDiagnosis;
@property (nonatomic, strong) NSString *familyHistory;
@property (nonatomic, strong) NSString *birthdate;

@end
