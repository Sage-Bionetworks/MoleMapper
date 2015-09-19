//
//  SBBScheduleManagerUnitTests.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/24/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeAPIUnitTestCase.h"
#import "SBBScheduleManagerInternal.h"
#import "SBBBridgeObjects.h"

@interface SBBScheduleManagerUnitTests : SBBBridgeAPIUnitTestCase

@end

@implementation SBBScheduleManagerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetSchedules {
    NSArray *schedules =
    @[
      @{
          @"type": @"Schedule",
          @"label": @"Schedule 1 Label",
          @"activities": @[
                  @{
                      @"activityType": @"survey",
                      @"label": @"This is a survey",
                      @"survey": @{
                              @"identifier": @"this-is-a-survey",
                              @"guid": @"guid-goes-here",
                              @"createdOn": @"2014-12-12T18:26:01.855Z",
                              @"href": @"url-to-retrieve-survey/guid-goes-here/2014-12-12T18:26:01.855Z",
                              @"type": @"SurveyReference"
                              },
                      @"type": @"Activity"
                      },
                  @{
                      @"activityType": @"task",
                      @"label": @"This is a task",
                      @"labelDetail": @"It will be tricky and frustrating to perform",
                      @"task": @{
                              @"identifier": @"this-is-a-task",
                              @"type": @"TaskReference"
                              },
                      @"type": @"Activity"
                      }
                  ],
          @"scheduleType": @"once",
          @"delay": @"PT3H",
          @"eventId": @"completedOn:survey:e3ec1b8b-3d82-4fa2-9516-5b18895ec924"
          }
      ];
    NSDictionary *response = @{
                                  @"type": @"ResourceList",
                                  @"items": schedules,
                                  @"total": @(schedules.count)
                                  };

    [self.mockURLSession setJson:response andResponseCode:200 forEndpoint:kSBBScheduleAPI andMethod:@"GET"];
    id <SBBScheduleManagerProtocol> sMan = SBBComponent(SBBScheduleManager);
    
    [sMan getSchedulesWithCompletion:^(SBBResourceList *schedulesRList, NSError *error) {
        XCTAssert([schedulesRList isKindOfClass:[SBBResourceList class]], @"Converted incoming json to SBBResourceList");
        NSArray *schedules = schedulesRList.items;
        XCTAssert([schedules isKindOfClass:[NSArray class]], @"Converted items to NSArray");
        XCTAssert(schedules.count, @"Converted items to non-empty NSArray");
        if (schedules.count) {
            SBBSchedule *schedule0 = schedules[0];
            XCTAssert([schedule0 isKindOfClass:[SBBSchedule class]], @"Converted items to NSArray of SBBSchedule objects");
            SBBActivity *activity0 = schedule0.activities[0];
            XCTAssert([activity0 isKindOfClass:[SBBActivity class]], @"Converted 'activities' json to NSArray and first item is an SBBActivity object");
            XCTAssert([activity0.survey isKindOfClass:[SBBSurveyReference class]], @"Converted 'survey' json to SBBSurveyReference object");
            SBBActivity *activity1 = schedule0.activities[1];
            XCTAssert([activity1 isKindOfClass:[SBBActivity class]], @"Second item of 'activities' is also an SBBActivity object");
            XCTAssert([activity1.activityType isEqualToString:@"task"], @"Put activities into array in correct order");
            XCTAssert([activity1.task isKindOfClass:[SBBTaskReference class]], @"Converted 'task' json to SBBTaskReference object");
        }
    }];
}

@end
