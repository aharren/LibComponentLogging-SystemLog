//
//
// SystemLogTestsConfigurationTests.m
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


@interface SystemLogTestsConfigurationTests : SenTestCase {
    
}

@end


@implementation SystemLogTestsConfigurationTests

- (void)setUp {
}

- (void)testConfigurationMirrorsToStdErr {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setMirrorMessagesToStdErr:YES];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog mirrorsToStdErr], (int)YES, nil);
    
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setMirrorMessagesToStdErr:NO];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog mirrorsToStdErr], (int)NO, nil);
}

- (void)testConfigurationUsesPerThreadConnections {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:YES];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog usesPerThreadConnections], (int)YES, nil);
    
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:NO];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog usesPerThreadConnections], (int)NO, nil);
}

- (void)testShowsFileNames {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsFileNames], (int)YES, nil);
    
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowFileNames:NO];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsFileNames], (int)NO, nil);
}

- (void)testShowsLineNumbers {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsLineNumbers], (int)YES, nil);
    
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:NO];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsLineNumbers], (int)NO, nil);
}

- (void)testShowsFunctionNames {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsFunctionNames], (int)YES, nil);
    
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:NO];
    [LCLSystemLog initialize];
    STAssertEquals((int)[LCLSystemLog showsFunctionNames], (int)NO, nil);
}

@end

