//
//
// SystemLogTestsTemplatesTests.m
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


@interface SystemLogTestsTemplatesTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsTemplatesTests

#undef  as_NSString
#define as_NSString( _text) as_NSString0(_text)
#define as_NSString0(_text) @#_text

- (void)setUp {
}

- (void)testClassNames {
    STAssertEqualObjects(as_NSString(LCLSystemLog), @"TestLCLSystemLog", nil);
    STAssertEqualObjects(as_NSString(LCLSystemLogConnection), @"TestLCLSystemLogConnection", nil);
}

- (void)testConfigurationMirrorsToStdErr {
    STAssertEquals((int)[LCLSystemLog mirrorsToStdErr], (int)NO, nil);
}

- (void)testConfigurationUsesPerThreadConnections {
    STAssertEquals((int)[LCLSystemLog usesPerThreadConnections], (int)YES, nil);
}

- (void)testShowsFileNames {
    STAssertEquals((int)[LCLSystemLog showsFileNames], (int)YES, nil);
}

- (void)testShowsLineNumbers {
    STAssertEquals((int)[LCLSystemLog showsLineNumbers], (int)YES, nil);
}

- (void)testShowsFunctionNames {
    STAssertEquals((int)[LCLSystemLog showsFunctionNames], (int)YES, nil);
}

- (void)testLastASLLogLevelToUse {
    STAssertEquals((uint32_t)[LCLSystemLog lastASLLogLevelToUse], (uint32_t)7/*ASL_LEVEL_DEBUG*/, nil);
}

@end
