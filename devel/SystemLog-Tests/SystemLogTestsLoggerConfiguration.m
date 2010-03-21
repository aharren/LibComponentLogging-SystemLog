//
//
// SystemLogTestsLoggerConfiguration.m
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

#import "SystemLogTestsLoggerConfiguration.h"


static BOOL SystemLogTestsLoggerConfiguration_mirrorMessagesToStdErr = NO;
static BOOL SystemLogTestsLoggerConfiguration_usePerThreadConnections = NO;
static BOOL SystemLogTestsLoggerConfiguration_showFileNames = NO;
static BOOL SystemLogTestsLoggerConfiguration_showLineNumbers = NO;
static BOOL SystemLogTestsLoggerConfiguration_showFunctionNames = NO;


@implementation SystemLogTestsLoggerConfiguration

+ (void)initialize {
    SystemLogTestsLoggerConfiguration_mirrorMessagesToStdErr = NO;
    SystemLogTestsLoggerConfiguration_usePerThreadConnections = NO;
    SystemLogTestsLoggerConfiguration_showFileNames = NO;
    SystemLogTestsLoggerConfiguration_showLineNumbers = NO;
    SystemLogTestsLoggerConfiguration_showFunctionNames = NO;
}

+ (BOOL)mirrorMessagesToStdErr {
    return SystemLogTestsLoggerConfiguration_mirrorMessagesToStdErr;
}

+ (void)setMirrorMessagesToStdErr:(BOOL)mirror {
    SystemLogTestsLoggerConfiguration_mirrorMessagesToStdErr = mirror;
}

+ (BOOL)usePerThreadConnections {
    return SystemLogTestsLoggerConfiguration_usePerThreadConnections;
}

+ (void)setUsePerThreadConnections:(BOOL)perThread {
    SystemLogTestsLoggerConfiguration_usePerThreadConnections = perThread;
}

+ (BOOL)showFileNames {
    return SystemLogTestsLoggerConfiguration_showFileNames;
}

+ (void)setShowFileNames:(BOOL)show {
    SystemLogTestsLoggerConfiguration_showFileNames = show;
}

+ (BOOL)showLineNumbers {
    return SystemLogTestsLoggerConfiguration_showLineNumbers;
}

+ (void)setShowLineNumbers:(BOOL)show {
    SystemLogTestsLoggerConfiguration_showLineNumbers = show;
}

+ (BOOL)showFunctionNames {
    return SystemLogTestsLoggerConfiguration_showFunctionNames;
}

+ (void)setShowFunctionNames:(BOOL)show {
    SystemLogTestsLoggerConfiguration_showFunctionNames = show;
}

@end

