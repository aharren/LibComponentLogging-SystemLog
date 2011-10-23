//
//
// SystemLogTestsPerThreadConnectionsTest.m
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
#import <unistd.h>
#import <asl.h>


@interface LCLSystemLogConnection : NSObject {
    
}

- (aslclient)aslClient;
- (void)setAslClient:(aslclient)client;
- (void)unsetAslClientUnsafe;

@end


@interface SystemLogTestsPerThreadConnectionsTest : SenTestCase {
    
}

@end


@implementation SystemLogTestsPerThreadConnectionsTest

- (void)setUp {
    // clear the per-thread ASL connection on the main thread
    [[[NSThread currentThread] threadDictionary] removeObjectForKey:@"SystemLogTestsLCLSystemLogConnection"];
}

- (void)testPerThreadConnectionsOnMainThread {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:YES];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    // per-thread ASL connection should not exist
    LCLSystemLogConnection *connection = nil;
    connection = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
    STAssertNil(connection, nil);
    
    // log on main thread
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-ident" level:3 path:"path/file" line:1 function:"f" message:@"message 1"];
    
    // per-thread ASL connection should exist
    connection = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
    STAssertNotNil(connection, nil);
    STAssertTrue([connection aslClient] != NULL, nil);
    
    // re-configure the per-thread ASL connection to make sure it is really used
    STAssertTrue([connection aslClient] != NULL, nil);
    asl_set_filter([connection aslClient], ASL_FILTER_MASK_UPTO(ASL_LEVEL_CRIT));
    
    // log again on main thread, this should not be logged
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-ident" level:3 path:"path/file" line:1 function:"f" message:@"message 2"];
    
    // per-thread ASL connection should be the same
    NSObject *connection2 = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
    STAssertNotNil(connection2, nil);
    STAssertEquals((NSObject *)connection, (NSObject *)connection2, nil);
    
    // re-configure the per-thread ASL connection once more
    STAssertTrue([connection aslClient] != NULL, nil);
    asl_set_filter([connection aslClient], ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    
    // log again on main thread
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-ident" level:4 path:"path/file" line:1 function:"f" message:@"message 3"];
    
    // check messages
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)2, nil);
    
    ASLMessage *message1 = [messages messageAtIndex:0];
    STAssertEqualObjects([message1 valueForKey:@"Facility"], @"PerThreadConnectionsTest-ident", nil);
    STAssertEqualObjects([message1 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message1 valueForKey:@"Level"], @"3", nil);
    STAssertEqualObjects([message1 valueForKey:@"Level0"], @"E", nil);
    STAssertEqualObjects([message1 valueForKey:@"File"], @"file", nil);
    STAssertEqualObjects([message1 valueForKey:@"Line"], @"1", nil);
    STAssertEqualObjects([message1 valueForKey:@"Function"], @"f", nil);
    STAssertEqualObjects([message1 valueForKey:@"Message"], @"message 1", nil);
    
    ASLMessage *message2 = [messages messageAtIndex:1];
    STAssertEqualObjects([message2 valueForKey:@"Facility"], @"PerThreadConnectionsTest-ident", nil);
    STAssertEqualObjects([message2 valueForKey:@"Thread"], thread, nil);
    STAssertEqualObjects([message2 valueForKey:@"Level"], @"4", nil);
    STAssertEqualObjects([message2 valueForKey:@"Level0"], @"W", nil);
    STAssertEqualObjects([message2 valueForKey:@"File"], @"file", nil);
    STAssertEqualObjects([message2 valueForKey:@"Line"], @"1", nil);
    STAssertEqualObjects([message2 valueForKey:@"Function"], @"f", nil);
    STAssertEqualObjects([message2 valueForKey:@"Message"], @"message 3", nil);
}

static NSCondition *thread1Finished = nil;
static NSObject *thread1ConnectionAtStart = nil;
static NSObject *thread1ConnectionAtEnd = nil;

- (void)thread1Main {
    thread1ConnectionAtStart = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
#   if !__has_feature(objc_arc)
    [thread1ConnectionAtStart retain];
#   endif
    
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-thread1" level:3 path:"path/file1" line:1 function:"f1" message:@"message: thread1"];
    
    thread1ConnectionAtEnd = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
#   if !__has_feature(objc_arc)
    [thread1ConnectionAtEnd retain];
#   endif
    
    [thread1Finished lock];
    [thread1Finished signal];
    [thread1Finished unlock];
}

static NSCondition *thread2Finished = nil;
static NSObject *thread2ConnectionAtStart = nil;
static NSObject *thread2ConnectionAtEnd = nil;

- (void)thread2Main {
    thread2ConnectionAtStart = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
#   if !__has_feature(objc_arc)
    [thread2ConnectionAtStart retain];
#   endif
    
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-thread2" level:3 path:"path/file2" line:2 function:"f2" message:@"message: thread2"];
    
    thread2ConnectionAtEnd = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
#   if !__has_feature(objc_arc)
    [thread2ConnectionAtEnd retain];
#   endif
    
    [thread2Finished lock];
    [thread2Finished signal];
    [thread2Finished unlock];
}

- (void)testPerThreadConnectionsWith2NewsThreads {
    [SystemLogTestsLoggerConfiguration initialize];
    [SystemLogTestsLoggerConfiguration setUsePerThreadConnections:YES];
    [SystemLogTestsLoggerConfiguration setShowFileNames:YES];
    [SystemLogTestsLoggerConfiguration setShowLineNumbers:YES];
    [SystemLogTestsLoggerConfiguration setShowFunctionNames:YES];
    [LCLSystemLog initialize];
    
    NSString *thread = [NSString stringWithFormat:@"%x", mach_thread_self()];
    
    ASLReferenceMark *mark = [[ASLReferenceMark alloc] init];
#   if !__has_feature(objc_arc)
    [mark autorelease];
#   endif
    
    // per-thread ASL connection should not exist
    NSObject *connection = nil;
    connection = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
    STAssertNil(connection, nil);
    
    // start 2 threads
    thread1Finished = [[NSCondition alloc] init];
    [thread1Finished lock];
    [NSThread detachNewThreadSelector:@selector(thread1Main) toTarget:self withObject:nil];
    thread2Finished = [[NSCondition alloc] init];
    [thread2Finished lock];
    [NSThread detachNewThreadSelector:@selector(thread2Main) toTarget:self withObject:nil];
    
    // log on main thread
    [LCLSystemLog logWithIdentifier:"PerThreadConnectionsTest-main" level:3 path:"path/file0" line:0 function:"f0" message:@"message: main"];
    
    // per-thread ASL connection should exist on the main thread
    connection = [[[NSThread currentThread] threadDictionary] objectForKey:@"SystemLogTestsLCLSystemLogConnection"];
    STAssertNotNil(connection, nil);
    
    // wait for the threads
    [thread1Finished wait];
    [thread1Finished unlock];
    [thread2Finished wait];
    [thread2Finished unlock];
    
    // per-thread ASL connection should not exist in the threads at start
    STAssertNil(thread1ConnectionAtStart, nil);
    STAssertNil(thread2ConnectionAtStart, nil);
    
    // per-thread ASL connection should exist in the threads after logging
    STAssertNotNil(thread1ConnectionAtEnd, nil);
    STAssertNotNil(thread2ConnectionAtEnd, nil);
    
    // per-thread ASL connection should have been destroyed
    sleep(2);
#   if !__has_feature(objc_arc)
    STAssertEquals([thread1ConnectionAtEnd retainCount], (NSUInteger)1, nil);
    [thread1ConnectionAtEnd release];
    STAssertEquals([thread2ConnectionAtEnd retainCount], (NSUInteger)1, nil);
    [thread2ConnectionAtEnd release];
#   endif
    
    // check messages
    ASLMessageArray *messages = [ASLDataStore messagesSinceReferenceMark:mark];
    STAssertEquals([messages count], (NSUInteger)3, nil);
    
    BOOL messageMainSeen = NO;
    BOOL messageThread1Seen = NO;
    BOOL messageThread2Seen = NO;
    for (NSUInteger i = 0; i < 3; i++) {
        ASLMessage *message = [messages messageAtIndex:i];
        NSString *facility = [message valueForKey:@"Facility"];
        if ([facility isEqualToString:@"PerThreadConnectionsTest-main"]) {
            messageMainSeen = YES;
            STAssertEqualObjects([message valueForKey:@"Facility"], @"PerThreadConnectionsTest-main", nil);
            STAssertEqualObjects([message valueForKey:@"Thread"], thread, nil);
            STAssertEqualObjects([message valueForKey:@"Level"], @"3", nil);
            STAssertEqualObjects([message valueForKey:@"Level0"], @"E", nil);
            STAssertEqualObjects([message valueForKey:@"File"], @"file0", nil);
            STAssertEqualObjects([message valueForKey:@"Line"], @"0", nil);
            STAssertEqualObjects([message valueForKey:@"Function"], @"f0", nil);
            STAssertEqualObjects([message valueForKey:@"Message"], @"message: main", nil);
        } else if ([facility isEqualToString:@"PerThreadConnectionsTest-thread1"]) {
            messageThread1Seen = YES;
            STAssertEqualObjects([message valueForKey:@"Facility"], @"PerThreadConnectionsTest-thread1", nil);
            STAssertFalse([thread isEqualToString:[message valueForKey:@"Thread"]], nil);
            STAssertEqualObjects([message valueForKey:@"Level"], @"3", nil);
            STAssertEqualObjects([message valueForKey:@"Level0"], @"E", nil);
            STAssertEqualObjects([message valueForKey:@"File"], @"file1", nil);
            STAssertEqualObjects([message valueForKey:@"Line"], @"1", nil);
            STAssertEqualObjects([message valueForKey:@"Function"], @"f1", nil);
            STAssertEqualObjects([message valueForKey:@"Message"], @"message: thread1", nil);
        } else if ([facility isEqualToString:@"PerThreadConnectionsTest-thread2"]) {
            messageThread2Seen = YES;
            STAssertEqualObjects([message valueForKey:@"Facility"], @"PerThreadConnectionsTest-thread2", nil);
            STAssertFalse([thread isEqualToString:[message valueForKey:@"Thread"]], nil);
            STAssertEqualObjects([message valueForKey:@"Level"], @"3", nil);
            STAssertEqualObjects([message valueForKey:@"Level0"], @"E", nil);
            STAssertEqualObjects([message valueForKey:@"File"], @"file2", nil);
            STAssertEqualObjects([message valueForKey:@"Line"], @"2", nil);
            STAssertEqualObjects([message valueForKey:@"Function"], @"f2", nil);
            STAssertEqualObjects([message valueForKey:@"Message"], @"message: thread2", nil);
        } else {
            STFail(nil);
        }
    }
    STAssertTrue(messageMainSeen, nil);
    STAssertTrue(messageThread1Seen, nil);
    STAssertTrue(messageThread2Seen, nil);
}

- (void)testPerThreadConnectionsConnectionHolderBehavior {
    LCLSystemLogConnection *connection = [[LCLSystemLogConnection alloc] init];
    
    // set client
    [connection setAslClient:(aslclient)1];
    
    @try {
        // set client again
        [connection setAslClient:(aslclient)2];
        STFail(@"[setAslClient] should throw NSInvalidArgumentException");
        
    } @catch (NSException *exception) {
        STAssertEquals([exception name], NSInvalidArgumentException, nil);
        
    } @catch (...) {
        STFail(@"[setAslClient] should throw NSInvalidArgumentException");
    }

    // unset client to avoid crashes on release
    [connection unsetAslClientUnsafe];

#   if !__has_feature(objc_arc)
    [connection release];
#   endif
}

@end

