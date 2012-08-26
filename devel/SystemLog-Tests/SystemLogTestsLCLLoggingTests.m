//
//
// SystemLogTestsLCLLoggingTests.m
//
//
// Copyright (c) 2008-2012 Arne Harren <ah@0xc0.de>
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


@interface SystemLogTestsLCLLoggingTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsLCLLoggingTests

- (void)setUp {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    // enable logging for component Main and MainComponent1
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
    lcl_configure_by_component(lcl_cMainComponent1, lcl_vDebug);
    lcl_configure_by_component(lcl_cMainComponent2, lcl_vDebug);
}

- (void)testLoggingWithVarArgsLogMethod {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    [LCLSystemLog logWithIdentifier:_lcl_component_header[lcl_cMain] lclLevel:lcl_vInfo path:"path/file1a" line:101 function:"f1" format:@"format %d %@", 1, @"message"];
    [LCLSystemLog logWithIdentifier:_lcl_component_header[lcl_cMain] lclLevel:lcl_vError path:"path/file1b" line:102 function:"f2" format:@"format %d %@", 2, @"message"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)2, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file1a", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"101", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"f1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"format 1 message", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"main", nil);
    STAssertEqualObjects([message2 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"E", nil);
    STAssertEqualObjects([message2 valueForKey:@"File"], @"file1b", nil);
    STAssertEqualObjects([message2 valueForKey:@"Line"], @"102", nil);
    STAssertEqualObjects([message2 valueForKey:@"Function"], @"f2", nil);
    STAssertEqualObjects([message2 valueForKey:@"Message"], @"format 2 message", nil);
}

- (void)loggingWithVaListVarArgsLogMethodHelper:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [LCLSystemLog logWithIdentifier:_lcl_component_header[lcl_cMainComponent1] lclLevel:lcl_vInfo path:"file2" line:200 function:"function" format:format args:args];
    va_end(args);
}

- (void)testLoggingWithVaListVarArgsLogMethod {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    [self loggingWithVaListVarArgsLogMethodHelper:@"message %d %@ %d", 2, @"abc", 3];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main.component1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file2", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"200", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"function", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message 2 abc 3", nil);
}

- (void)testLoggingWithMessage {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    [LCLSystemLog logWithIdentifier:_lcl_component_header[lcl_cMainComponent2] lclLevel:lcl_vError path:"file3" line:300 function:"function" message:@"message %d %@"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main.component2", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"E", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file3", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"300", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"function", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message %d %@", nil);
}

- (void)testLoggingWithLogMacro {
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    lcl_log(lcl_cMainComponent1, lcl_vInfo, @"message with macro, %d", 1);
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main.component1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"SystemLogTestsLCLLoggingTests.m", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"154", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"-[SystemLogTestsLCLLoggingTests testLoggingWithLogMacro]", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message with macro, 1", nil);
}

@end

