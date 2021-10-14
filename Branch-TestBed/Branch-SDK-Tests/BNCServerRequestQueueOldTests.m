//
//  BNCServerRequestQueueTests.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 6/17/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BNCTestCase.h"
#import "BNCServerRequestQueue.h"
#import "BranchOpenRequest.h"
#import "BranchCloseRequest.h"
#import <OCMock/OCMock.h>
#import "Branch.h"

@interface BNCServerRequestQueue (BNCTests)
- (void)retrieve;
- (void)cancelTimer;
@end

@interface BNCServerRequestQueueOldTests : BNCTestCase
@end

@implementation BNCServerRequestQueueOldTests

#pragma mark - MoveOpenOrInstallToFront tests

+ (void) setUp {
    [self clearAllBranchSettings]; // Clear any saved data before our tests start.
//    Branch*branch = [Branch getInstance:@"key_live_foo"];
//    [self clearAllBranchSettings];
}

- (void)testMoveOpenOrInstallToFrontWhenEmpty {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    XCTAssertNoThrow([requestQueue moveInstallOrOpenToFront:0]);
}

- (void)testMoveOpenOrInstallToFrontWhenNotPresent {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    XCTAssertNoThrow([requestQueue moveInstallOrOpenToFront:0]);
}

- (void)testMoveOpenOrInstallToFrontWhenAlreadyInFrontAndNoRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    [requestQueue insert:[[BranchOpenRequest alloc] init] at:0];
    
    id requestQueueMock = OCMPartialMock(requestQueue);
    [[requestQueueMock reject] removeAt:0];
    
    [requestQueue moveInstallOrOpenToFront:0];
}

- (void)testMoveOpenOrInstallToFrontWhenAlreadyInFrontWithRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    [requestQueue insert:[[BranchOpenRequest alloc] init] at:0];

    id requestQueueMock = OCMPartialMock(requestQueue);
    [[requestQueueMock reject] removeAt:0];
    
    [requestQueue moveInstallOrOpenToFront:1];
}

- (void)testMoveOpenOrInstallToFrontWhenSecondInLineWithRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    [requestQueue insert:[[BranchOpenRequest alloc] init] at:1];
    
    id requestQueueMock = OCMPartialMock(requestQueue);
    [[requestQueueMock reject] removeAt:1];
    
    [requestQueue moveInstallOrOpenToFront:1];
}

- (void)testMoveOpenOrInstallToFrontWhenSecondInLineWithNoRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    BranchOpenRequest *openRequest = [[BranchOpenRequest alloc] init];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    [requestQueue insert:openRequest at:1];
    
    id requestQueueMock = OCMPartialMock(requestQueue);
    [[[requestQueueMock expect] andForwardToRealObject] removeAt:1];
    
    [requestQueue moveInstallOrOpenToFront:0];
    XCTAssertEqual([requestQueue peek], openRequest);
    
    [requestQueueMock verify];
}

- (void)testMoveOpenOrInstallToFrontWhenThirdInLineWithRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    BranchOpenRequest *openRequest = [[BranchOpenRequest alloc] init];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:1];
    [requestQueue insert:openRequest at:2];
    
    id requestQueueMock = OCMPartialMock(requestQueue);
    [[[requestQueueMock expect] andForwardToRealObject] removeAt:2];
    
    [requestQueue moveInstallOrOpenToFront:1];
    XCTAssertEqual([requestQueue peekAt:1], openRequest);
    
    [requestQueueMock verify];
}

- (void)testMoveOpenOrInstallToFrontWhenThirdInLineWithNoRequestsInProgress {
    BNCServerRequestQueue *requestQueue = [[BNCServerRequestQueue alloc] init];
    BranchOpenRequest *openRequest = [[BranchOpenRequest alloc] init];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:0];
    [requestQueue insert:[[BNCServerRequest alloc] init] at:1];
    [requestQueue insert:openRequest at:2];
    
    id requestQueueMock = OCMPartialMock(requestQueue);
    [[[requestQueueMock expect] andForwardToRealObject] removeAt:2];
    
    [requestQueue moveInstallOrOpenToFront:0];
    XCTAssertEqual([requestQueue peek], openRequest);
    
    [requestQueueMock verify];
}

@end
