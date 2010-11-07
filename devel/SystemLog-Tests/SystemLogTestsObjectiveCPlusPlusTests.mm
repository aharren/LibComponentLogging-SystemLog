//
//
// SystemLogTestsObjectiveCPlusPlusTests.mm
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
#include <asl.h>


class SystemLogTestsObjectiveCPlusPlusTestsClass {
    
public:
    static void logAtLevelInfo(int i, NSString *t);
    
};

void SystemLogTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int i, NSString *t) {
    lcl_log(lcl_cMain, lcl_vInfo, @"message %s %d %@", "cstring", i, t);
}


@interface SystemLogTestsObjectiveCPlusPlusTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsObjectiveCPlusPlusTests

- (void)setUp {
    // enable logging for component Main
    lcl_configure_by_name("*", lcl_vOff);
    lcl_configure_by_component(lcl_cMain, lcl_vDebug);
}

- (void)testLogFormatWithComponentLineNumberAndFunctionName {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    SystemLogTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(123, @"NSString *");
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"main", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"I", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"SystemLogTestsObjectiveCPlusPlusTests.mm", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"41", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"static void SystemLogTestsObjectiveCPlusPlusTestsClass::logAtLevelInfo(int, NSString*)", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message cstring 123 NSString *", nil);
}

@end

