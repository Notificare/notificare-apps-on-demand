//
//  appTests.m
//  appTests
//
//  Created by Aernout Peeters on 14-12-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UIColor+Hex.h"

@interface appTests : XCTestCase

@end

@implementation appTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUIColorAndHex {
    NSString *shortOrangeString             = @"#f80";
    NSString *shortBlueTransparentString    = @"00FC";
    NSString *longGreenString               = @"#00F334";
    NSString *longPinkTransparentString     = @"ff67de5a";
    
    UIColor *orangeColor            = [UIColor colorWithRed:255/255.0 green:136/255.0 blue:0/255.0 alpha:255/255.0];
    UIColor *blueTransparentColor   = [UIColor colorWithRed:0.0 green:0/255.0 blue:255/255.0 alpha:204/255.0];
    UIColor *greenColor             = [UIColor colorWithRed:0/255.0 green:243/255.0 blue:52/255.0 alpha:255/255.0];
    UIColor *pinkTransparentColor   = [UIColor colorWithRed:255/255.0 green:103/255.0 blue:222/255.0 alpha:90/255.0];
    
    XCTAssertEqualObjects([UIColor colorWithHexString:shortOrangeString], orangeColor);
    XCTAssertEqualObjects([UIColor colorWithHexString:shortBlueTransparentString], blueTransparentColor);
    XCTAssertEqualObjects([UIColor colorWithHexString:longGreenString], greenColor);
    XCTAssertEqualObjects([UIColor colorWithHexString:longPinkTransparentString], pinkTransparentColor);
}

@end
