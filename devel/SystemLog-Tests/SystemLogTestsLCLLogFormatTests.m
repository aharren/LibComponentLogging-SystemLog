//
//
// SystemLogTestsLCLLogFormatTests.m
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


@interface SystemLogTestsLCLLogFormatTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsLCLLogFormatTests

- (void)setUp {
}

- (void)testLogFormatLogLevels {
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    [LCLSystemLog logWithIdentifier:"i1" lclLevel:0 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i2" lclLevel:1 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i3" lclLevel:2 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i4" lclLevel:3 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i5" lclLevel:4 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i6" lclLevel:5 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i7" lclLevel:6 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i8" lclLevel:7 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"i9" lclLevel:8 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"ia" lclLevel:9 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"ib" lclLevel:18 path:"path/file" line:0 function:"f" format:@"message"];
    [LCLSystemLog logWithIdentifier:"ic" lclLevel:(uint32_t)-1 path:"path/file" line:0 function:"f" format:@"message"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)4, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"i2", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"2", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"C", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"i3", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"E", nil);
    
    ASLMessage *message3 = [messages messageAtIndex:2];
    STAssertEqualObjects([message3 valueForKey:@"Facility"], @"i4", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level"], @"4", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level0"], @"W", nil);
    
    ASLMessage *message4 = [messages messageAtIndex:3];
    STAssertEqualObjects([message4 valueForKey:@"Facility"], @"i5", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level0"], @"I", nil);
}

@end

