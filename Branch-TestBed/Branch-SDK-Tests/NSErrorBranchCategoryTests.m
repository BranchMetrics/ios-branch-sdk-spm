/**
 @file          NSErrorBranchCategoryTests.m
 @package       Branch-SDK
 @brief         Branch error tests.

 @author        Edward Smith
 @date          August 2017
 @copyright     Copyright © 2017 Branch. All rights reserved.
*/

#import "BNCTestCase.h"
#import "NSError+Branch.h"

@interface NSErrorBranchCategoryTests : BNCTestCase
@end

@implementation NSErrorBranchCategoryTests

- (void) testErrorBasic {

    NSError *error = nil;
    error = [NSError branchErrorWithCode:BNCInitError];
    XCTAssert(error.domain == [NSError bncErrorDomain]);
    XCTAssert(error.code == BNCInitError);
    XCTAssert([error.localizedDescription isEqualToString:
        @"The Branch user session has not been initialized."]
    );

    NSError *underlyingError =
        [NSError errorWithDomain:NSCocoaErrorDomain
            code:NSFileNoSuchFileError userInfo:nil];
    error = [NSError branchErrorWithCode:BNCServerProblemError error:underlyingError];
    XCTAssert(error.domain == [NSError bncErrorDomain]);
    XCTAssert(error.code == BNCServerProblemError);
    XCTAssert(
        [error.localizedDescription isEqualToString:
            @"Trouble reaching the Branch servers, please try again shortly."]
    );
    XCTAssert(error.userInfo[NSUnderlyingErrorKey] == underlyingError);
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        XCTAssert([error.localizedFailureReason isEqualToString:
            @"The operation couldn’t be completed. (Cocoa error 4.)"]);
    } else {
        XCTAssert([error.localizedFailureReason isEqualToString:@"The file doesn’t exist."]);
    }

    NSString *message = [NSString stringWithFormat:@"Network operation of class '%@' does not conform to the BNCNetworkOperationProtocol.",
                         NSStringFromClass([self class])];
    error = [NSError branchErrorWithCode:BNCNetworkServiceInterfaceError localizedMessage:message];
    XCTAssert(error.domain == [NSError bncErrorDomain]);
    XCTAssert(error.code == BNCNetworkServiceInterfaceError);
    XCTAssert([error.localizedDescription isEqualToString:
        @"The underlying network service does not conform to the BNCNetworkOperationProtocol."]);
    XCTAssert([error.localizedFailureReason isEqualToString:
        @"Network operation of class 'NSErrorBranchCategoryTests' does not conform to the BNCNetworkOperationProtocol."]);
}

@end
