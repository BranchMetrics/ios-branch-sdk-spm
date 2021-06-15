//
//  BNCPreferenceHelperTests.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 4/2/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BNCPreferenceHelper.h"
#import "BNCEncodingUtils.h"
#import "BNCTestCase.h"

@interface BNCPreferenceHelperTests : BNCTestCase
@property (nonatomic, strong, readwrite) BNCPreferenceHelper *prefHelper;
@end

@implementation BNCPreferenceHelperTests

- (void)setUp {
    self.prefHelper = [BNCPreferenceHelper new];
}

- (void)tearDown {

}

- (void)testPreferenceDefaults {
    XCTAssertEqual(self.prefHelper.timeout, 5.5);
    XCTAssertEqual(self.prefHelper.retryInterval, 0);
    XCTAssertEqual(self.prefHelper.retryCount, 3);
    XCTAssertFalse(self.prefHelper.disableAdNetworkCallouts);
}

- (void)testPreferenceSets {
    self.prefHelper.retryCount = NSIntegerMax;
    self.prefHelper.retryInterval = NSIntegerMax;
    self.prefHelper.timeout = NSIntegerMax;
    
    XCTAssertEqual(self.prefHelper.retryCount, NSIntegerMax);
    XCTAssertEqual(self.prefHelper.retryInterval, NSIntegerMax);
    XCTAssertEqual(self.prefHelper.timeout, NSIntegerMax);
}

- (void)testBlacklistURL {
    XCTAssertTrue([@"https://cdn.branch.io" isEqualToString:self.prefHelper.branchBlacklistURL]);
    
    NSString *customBlacklistURL = @"https://blacklist.branch.io";
    self.prefHelper.branchBlacklistURL = customBlacklistURL;
    XCTAssertTrue([customBlacklistURL isEqualToString:self.prefHelper.branchBlacklistURL]);
}

@end
