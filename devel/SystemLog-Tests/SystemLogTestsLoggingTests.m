//
//
// SystemLogTestsLoggingTests.m
//
//
// Copyright (c) 2008-2010 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "lcl.h"
#import <SenTestingKit/SenTestingKit.h>
#import "ASLDataStore.h"
#include <mach/mach_init.h>


@interface SystemLogTestsLoggingTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsLoggingTests

- (void)setUp {
    // enable logging for component Main and MainComponent1
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
    lcl_configure_by_component(lcl_cMainComponent1, lcl_vDebug);
}

- (void)testLoggingWithVarArgsLogMethod {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    [LCLSystemLog writeComponent:lcl_cMain level:lcl_vInfo path:"path1a" line:101 message:@"format %d %@", 1, @"message"];
    [LCLSystemLog writeComponent:lcl_cMain level:lcl_vError path:"path1b" line:102 message:@"format %d %@", 2, @"message"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)2, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"path1a", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"101", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"format 1 message", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"main", nil);
    STAssertEqualObjects([message2 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"E", nil);
    STAssertEqualObjects([message2 valueForKey:@"File"], @"path1b", nil);
    STAssertEqualObjects([message2 valueForKey:@"Line"], @"102", nil);
    STAssertEqualObjects([message2 valueForKey:@"Message"], @"format 2 message", nil);
}

- (void)testLoggingWithLogMacro {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    lcl_log(lcl_cMainComponent1, lcl_vInfo, @"message with macro, %d", 1);
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main.component1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"SystemLogTestsLoggingTests.m", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"83", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message with macro, 1", nil);
}

@end

