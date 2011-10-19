//
//
// SystemLogTestsLCLLogFormatTests.m
//
//
// Copyright (c) 2008-2011 Arne Harren <ah@0xc0.de>
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


@interface SystemLogTestsLCLLogFormatTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsLCLLogFormatTests

- (void)setUp {
}

- (void)testLogFormatLogLevels {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
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

- (void)testLogFormatLogLevelsNoticeAsLastLevel {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [SystemLogTestsLoggerConfiguration setLastASLLogLevelToUse:(uint32_t)ASL_LEVEL_NOTICE];
    [LCLSystemLog initialize];
    
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
    STAssertEquals([messages count], (NSUInteger)12, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"i1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"-", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"i2", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"2", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"C", nil);
    
    ASLMessage *message3 = [messages messageAtIndex:2];
    STAssertEqualObjects([message3 valueForKey:@"Facility"], @"i3", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message3 valueForKey:@"Level0"], @"E", nil);
    
    ASLMessage *message4 = [messages messageAtIndex:3];
    STAssertEqualObjects([message4 valueForKey:@"Facility"], @"i4", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level"], @"4", nil);
    STAssertEqualObjects([message4 valueForKey:@"Level0"], @"W", nil);
    
    ASLMessage *message5 = [messages messageAtIndex:4];
    STAssertEqualObjects([message5 valueForKey:@"Facility"], @"i5", nil);
    STAssertEqualObjects([message5 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message5 valueForKey:@"Level0"], @"I", nil);
    
    ASLMessage *message6 = [messages messageAtIndex:5];
    STAssertEqualObjects([message6 valueForKey:@"Facility"], @"i6", nil);
    STAssertEqualObjects([message6 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message6 valueForKey:@"Level0"], @"D", nil);
    
    ASLMessage *message7 = [messages messageAtIndex:6];
    STAssertEqualObjects([message7 valueForKey:@"Facility"], @"i7", nil);
    STAssertEqualObjects([message7 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message7 valueForKey:@"Level0"], @"T", nil);
    
    ASLMessage *message8 = [messages messageAtIndex:7];
    STAssertEqualObjects([message8 valueForKey:@"Facility"], @"i8", nil);
    STAssertEqualObjects([message8 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message8 valueForKey:@"Level0"], @"7", nil);
    
    ASLMessage *message9 = [messages messageAtIndex:8];
    STAssertEqualObjects([message9 valueForKey:@"Facility"], @"i9", nil);
    STAssertEqualObjects([message9 valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([message9 valueForKey:@"Level0"], @"8", nil);
    
    ASLMessage *messagea = [messages messageAtIndex:9];
    STAssertEqualObjects([messagea valueForKey:@"Facility"], @"ia", nil);
    STAssertEqualObjects([messagea valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([messagea valueForKey:@"Level0"], @"9", nil);
    
    ASLMessage *messageb = [messages messageAtIndex:10];
    STAssertEqualObjects([messageb valueForKey:@"Facility"], @"ib", nil);
    STAssertEqualObjects([messageb valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([messageb valueForKey:@"Level0"], @"18", nil);
    
    ASLMessage *messagec = [messages messageAtIndex:11];
    STAssertEqualObjects([messagec valueForKey:@"Facility"], @"ic", nil);
    STAssertEqualObjects([messagec valueForKey:@"Level"], @"5", nil);
    STAssertEqualObjects([messagec valueForKey:@"Level0"], @"4294967295", nil);
}

- (void)loggingWithVaListVarArgsLogMethodHelper:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [LCLSystemLog logWithIdentifier:"ident" level:3 path:"file2" line:200 function:"function" format:format args:args];
    va_end(args);
}

- (void)testLoggingWithVaListVarArgsLogMethod {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    [self loggingWithVaListVarArgsLogMethodHelper:@"message %d %@ %d", 2, @"abc", 3];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"ident", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"E", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file2", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"200", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"function", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message 2 abc 3", nil);
}

- (void)testLoggingWithMessage {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[[ASLReferenceMark alloc] init] autorelease];
    
    [LCLSystemLog logWithIdentifier:"ident" level:1 path:"file3" line:300 function:"function" message:@"message %d %@"];
    
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)1, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"ident", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"A", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file3", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"300", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"function", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message %d %@", nil);
}

@end

