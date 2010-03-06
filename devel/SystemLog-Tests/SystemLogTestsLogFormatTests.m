//
//
// SystemLogTestsLogFormatTests.m
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

#import "LCLSystemLog.h"
#import <SenTestingKit/SenTestingKit.h>
#import "ASLDataStore.h"
#include <mach/mach_init.h>


@interface SystemLogTestsLogFormatTests_m : SenTestCase {
    
}

@end


@implementation SystemLogTestsLogFormatTests_m

- (void)setUp {
}

- (void)testLogFormatLogLevels {
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    [LCLSystemLog logWithIdentifier:"i1" level:0 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i2" level:1 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i3" level:2 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i4" level:3 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i5" level:4 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i6" level:5 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i7" level:6 path:"path/file" line:0 format:@"message"];    
    [LCLSystemLog logWithIdentifier:"i8" level:7 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"i9" level:8 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"ia" level:9 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"ib" level:18 path:"path/file" line:0 format:@"message"];
    [LCLSystemLog logWithIdentifier:"ic" level:(uint32_t)-1 path:"path/file" line:0 format:@"message"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)6, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"i1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"0", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"Y", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"i2", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"1", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"A", nil);
    
    ASLMessage *message3 = [messages messageAtIndex:2];
    STAssertEqualObjects([message3 valueForKey:@"Facility"], @"i3", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level"], @"2", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level0"], @"C", nil);
    
    ASLMessage *message4 = [messages messageAtIndex:3];
    STAssertEqualObjects([message4 valueForKey:@"Facility"], @"i4", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level0"], @"E", nil);
    
    ASLMessage *message5 = [messages messageAtIndex:4];
    STAssertEqualObjects([message5 valueForKey:@"Facility"], @"i5", nil);
    STAssertEqualObjects([message5 valueForKey:@"Level"], @"4", nil);
    STAssertEqualObjects([message5 valueForKey:@"Level0"], @"W", nil);
    
    ASLMessage *message6 = [messages messageAtIndex:5];
    STAssertEqualObjects([message6 valueForKey:@"Facility"], @"i6", nil);
    STAssertEqualObjects([message6 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message6 valueForKey:@"Level0"], @"N", nil);
}

@end

