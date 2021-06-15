//
//  BranchShortUrlRequestTests.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 6/12/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BNCTestCase.h"
#import "BranchShortUrlRequest.h"
#import "BranchConstants.h"
#import "BNCPreferenceHelper.h"
#import <OCMock/OCMock.h>
#import "BNCPreferenceHelper.h"
#import "BNCEncodingUtils.h"

@interface BranchShortUrlRequestTests : BNCTestCase
@end

@implementation BranchShortUrlRequestTests

- (void)testRequestBody {
    NSArray * const TAGS = @[];
    NSString * const ALIAS = @"foo-alias";
    BranchLinkType const LINK_TYPE = BranchLinkTypeOneTimeUse;
    NSInteger const DURATION = 1;
    NSString * const CHANNEL = @"foo-channel";
    NSString * const FEATURE = @"foo-feature";
    NSString * const STAGE = @"foo-stage";
    NSString * const CAMPAIGN = @"foo-campaign";
    NSDictionary * const PARAMS = @{};
    BNCLinkData * const LINK_DATA = [[BNCLinkData alloc] init];
    BNCLinkCache * const LINK_CACHE = [[BNCLinkCache alloc] init];

    [LINK_DATA setupType:LINK_TYPE];
    [LINK_DATA setupTags:TAGS];
    [LINK_DATA setupChannel:CHANNEL];
    [LINK_DATA setupFeature:FEATURE];
    [LINK_DATA setupStage:STAGE];
    [LINK_DATA setupAlias:ALIAS];
    [LINK_DATA setupMatchDuration:DURATION];
    [LINK_DATA setupParams:PARAMS];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    NSMutableDictionary * const expectedParams = NSMutableDictionary.new;
    expectedParams[BRANCH_REQUEST_KEY_SESSION_ID] = preferenceHelper.sessionID;
    expectedParams[BRANCH_REQUEST_KEY_BRANCH_IDENTITY] = preferenceHelper.identityID;
    expectedParams[BRANCH_REQUEST_KEY_DEVICE_FINGERPRINT_ID] = preferenceHelper.deviceFingerprintID;
    expectedParams[BRANCH_REQUEST_KEY_URL_ALIAS] = ALIAS;
    expectedParams[BRANCH_REQUEST_KEY_URL_CHANNEL] = CHANNEL;
    expectedParams[BRANCH_REQUEST_KEY_URL_DATA] = PARAMS;
    expectedParams[BRANCH_REQUEST_KEY_URL_DURATION] = @(DURATION);
    expectedParams[BRANCH_REQUEST_KEY_URL_FEATURE] = FEATURE;
    expectedParams[BRANCH_REQUEST_KEY_URL_LINK_TYPE] = @(LINK_TYPE);
    expectedParams[BRANCH_REQUEST_KEY_URL_SOURCE] = @"ios";
    expectedParams[BRANCH_REQUEST_KEY_URL_STAGE] = STAGE;
    expectedParams[BRANCH_REQUEST_KEY_URL_TAGS] = TAGS;

    BranchShortUrlRequest *request =
        [[BranchShortUrlRequest alloc]
            initWithTags:TAGS
            alias:ALIAS
            type:LINK_TYPE
            matchDuration:DURATION
            channel:CHANNEL
            feature:FEATURE
            stage:STAGE
            campaign:CAMPAIGN
            params:PARAMS
            linkData:LINK_DATA
            linkCache:LINK_CACHE
            callback:NULL];

    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [[serverInterfaceMock expect]
        postRequest:expectedParams
        url:[self stringMatchingPattern:BRANCH_REQUEST_ENDPOINT_GET_SHORT_URL]
        key:[OCMArg any]
        callback:[OCMArg any]];
    
    [request makeRequest:serverInterfaceMock key:nil callback:NULL];
    [serverInterfaceMock verify];
}

- (void)testRequestBodyWhenOptionalValuesArentProvided {
    BranchLinkType const LINK_TYPE = BranchLinkTypeOneTimeUse;
    BNCLinkData * const LINK_DATA = [[BNCLinkData alloc] init];
    BNCLinkCache * const LINK_CACHE = [[BNCLinkCache alloc] init];
    
    [LINK_DATA setupType:LINK_TYPE];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    NSMutableDictionary * const expectedParams = NSMutableDictionary.new;
    expectedParams[BRANCH_REQUEST_KEY_SESSION_ID] = preferenceHelper.sessionID;
    expectedParams[BRANCH_REQUEST_KEY_BRANCH_IDENTITY] = preferenceHelper.identityID;
    expectedParams[BRANCH_REQUEST_KEY_DEVICE_FINGERPRINT_ID] = preferenceHelper.deviceFingerprintID;
    expectedParams[BRANCH_REQUEST_KEY_URL_SOURCE] = @"ios";
    expectedParams[BRANCH_REQUEST_KEY_URL_LINK_TYPE] = @(LINK_TYPE);

    BranchShortUrlRequest *request =
        [[BranchShortUrlRequest alloc]
            initWithTags:nil
            alias:nil
            type:LINK_TYPE
            matchDuration:0
            channel:nil
            feature:nil
            stage:nil
            campaign:nil
            params:nil
            linkData:LINK_DATA
            linkCache:LINK_CACHE
            callback:NULL];

    id serverInterfaceMock = OCMClassMock([BNCServerInterface class]);
    [[serverInterfaceMock expect]
        postRequest:expectedParams
        url:[OCMArg any]
        key:[OCMArg any]
        callback:[OCMArg any]];
    
    [request makeRequest:serverInterfaceMock key:nil callback:NULL];
    
    [serverInterfaceMock verify];
}

- (void)testBasicSuccess {
    NSString * URL = @"http://foo";
    NSDictionary * const REFERRAL_RESPONSE_DATA = @{ BRANCH_RESPONSE_KEY_URL: URL };
    BNCServerResponse *response = [[BNCServerResponse alloc] init];
    response.data = REFERRAL_RESPONSE_DATA;
    
    XCTestExpectation *requestExpecation = [self expectationWithDescription:@"Get Referral Code Request Expectation"];
    BranchShortUrlRequest *request =
        [[BranchShortUrlRequest alloc]
            initWithTags:nil
            alias:nil
            type:BranchLinkTypeOneTimeUse
            matchDuration:1
            channel:nil
            feature:nil
            stage:nil
            campaign:nil
            params:nil
            linkData:nil
            linkCache:nil
            callback:^(NSString *url, NSError *error) {
        XCTAssertEqualObjects(url, URL);
        XCTAssertNil(error);
        [self safelyFulfillExpectation:requestExpecation];
    }];
    
    [request processResponse:response error:nil];
    
    [self awaitExpectations];
}

- (void)testFailureWithUserUrlAvailable {
    NSError * RESPONSE_ERROR = [NSError errorWithDomain:@"foo" code:1 userInfo:nil];
    NSString * USER_URL = @"http://foo";

    NSString * TAG1 = @"foo-tag";
    NSString * TAG2 = @"bar-tag";
    NSArray * const TAGS = @[ TAG1, TAG2 ];
    NSString * const ALIAS = @"foo-alias";
    BranchLinkType const LINK_TYPE = BranchLinkTypeOneTimeUse;
    NSInteger const DURATION = 1;
    NSString * const CHANNEL = @"foo-channel";
    NSString * const FEATURE = @"foo-feature";
    NSString * const STAGE = @"foo-stage";
    NSString * const CAMPAIGN = @"foo-campaign";
    NSDictionary * const PARAMS = @{ @"foo-param": @"bar-value" };
    NSData * const PARAMS_DATA = [BNCEncodingUtils encodeDictionaryToJsonData:PARAMS];
    NSString * const ENCODED_PARAMS = [BNCEncodingUtils base64EncodeData:PARAMS_DATA];
    
    NSString * EXPECTED_URL = [NSString stringWithFormat:
        @"%@?tags=%@&tags=%@&alias=%@&channel=%@&feature=%@&stage=%@&type=%ld&duration=%ld&source=ios&data=%@",
        USER_URL, TAG1, TAG2, ALIAS, CHANNEL, FEATURE, STAGE, (long)LINK_TYPE, (long)DURATION, ENCODED_PARAMS];
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    preferenceHelper.userUrl = USER_URL;
    
    XCTestExpectation *requestExpecation = [self expectationWithDescription:@"Get Referral Code Request Expectation"];
    BranchShortUrlRequest *request =
        [[BranchShortUrlRequest alloc]
            initWithTags:TAGS
            alias:ALIAS
            type:LINK_TYPE
            matchDuration:DURATION
            channel:CHANNEL
            feature:FEATURE
            stage:STAGE
            campaign:CAMPAIGN
            params:PARAMS
            linkData:nil
            linkCache:nil
            callback:^(NSString *url, NSError *error) {
        XCTAssertEqualObjects(url, EXPECTED_URL);
        XCTAssertNotNil(error);
        [self safelyFulfillExpectation:requestExpecation];
    }];
    
    [request processResponse:nil error:RESPONSE_ERROR];
    
    [self awaitExpectations];
}

- (void)testFailureWithoutUserUrlAvailable {
    NSError * RESPONSE_ERROR = [NSError errorWithDomain:@"foo" code:1 userInfo:nil];
    
    NSString * TAG1 = @"foo-tag";
    NSString * TAG2 = @"bar-tag";
    NSArray * const TAGS = @[ TAG1, TAG2 ];
    NSString * const ALIAS = @"foo-alias";
    BranchLinkType const LINK_TYPE = BranchLinkTypeOneTimeUse;
    NSInteger const DURATION = 1;
    NSString * const CHANNEL = @"foo-channel";
    NSString * const FEATURE = @"foo-feature";
    NSString * const CAMPAIGN = @"foo-campaign";
    NSString * const STAGE = @"foo-stage";
    NSDictionary * const PARAMS = @{ @"foo-param": @"bar-value" };
    
    BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper preferenceHelper];
    preferenceHelper.userUrl = nil;
    
    XCTestExpectation *requestExpecation =
        [self expectationWithDescription:@"testFailureWithoutUserUrlAvailable Expectation"];
    BranchShortUrlRequest *request =
        [[BranchShortUrlRequest alloc]
            initWithTags:TAGS
            alias:ALIAS
            type:LINK_TYPE
            matchDuration:DURATION
            channel:CHANNEL
            feature:FEATURE
            stage:STAGE
            campaign:CAMPAIGN
            params:PARAMS
            linkData:nil
            linkCache:nil
            callback:^(NSString *url, NSError *error) {
        XCTAssertTrue((Branch.branchKeyIsSet && url != nil) || (!Branch.branchKeyIsSet && url == nil));
        XCTAssertNotNil(error);
        [self safelyFulfillExpectation:requestExpecation];
    }];
    
    [request processResponse:nil error:RESPONSE_ERROR];
    
    [self awaitExpectations];
}

@end
