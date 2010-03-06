//
//
// LCLSystemLog.m
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

#ifndef _LCLSystemLog_MirrorMessagesToStdErr
#error  '_LCLSystemLog_MirrorMessagesToStdErr' must be defined in 'lcl_config_logger.h'
#endif

#include <asl.h>
#include <mach/mach_init.h>


// A lock which is held when the asl client connection is used.
static NSRecursiveLock *_LCLSystemLog_aslClientLock = nil;

// The asl client connection to use.
static aslclient _LCLSystemLog_aslClient = NULL;

// Log levels known by asl, indexed by LCL log level.
static const char * const _LCLSystemLog_aslLogLevel[] = {
    ASL_STRING_DEBUG,   // Off
    ASL_STRING_CRIT,    // Critical
    ASL_STRING_ERR,     // Error
    ASL_STRING_WARNING, // Warning
    ASL_STRING_NOTICE,  // Info
    ASL_STRING_DEBUG,   // Debug
    ASL_STRING_DEBUG    // Trace
};


@implementation LCLSystemLog

// No instances, please.
+(id)alloc {
    [LCLSystemLog doesNotRecognizeSelector:_cmd];
    return nil;
}

// Initializes the class.
+ (void)initialize {
    // perform initialization only once
    if (self != [LCLSystemLog class])
        return;
    
    // create the lock
    _LCLSystemLog_aslClientLock = [[NSRecursiveLock alloc] init];
    
    // open an asl client connection
    uint32_t client_opts = 0;
    if (_LCLSystemLog_MirrorMessagesToStdErr) {
        // mirror log messages to stderr if requested
        client_opts |= ASL_OPT_STDERR;
    }
    _LCLSystemLog_aslClient = asl_open(NULL, NULL, client_opts);
    
    // log all messages up to DEBUG
    if (_LCLSystemLog_aslClient != NULL) {
        asl_set_filter(_LCLSystemLog_aslClient, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    }
}

// Writes the given log message to the system log.
+ (void)writeComponent:(_lcl_component_t)component level:(_lcl_level_t)level
                  path:(const char *)path line:(uint32_t)line
               message:(NSString *)message, ... {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // get file from path
    const char *file_c = strrchr(path, '/');
    file_c = (file_c != NULL) ? (file_c + 1) : (path);
    
    // get line number
    char line_c[12];
    snprintf(line_c, sizeof(line_c), "%d", line);
    
    // get thread id
    char tid_c[10];
    snprintf(tid_c, sizeof(tid_c), "%x", mach_thread_self());
    
    // create log message
    va_list args;
    va_start(args, message);
    NSString *msg = [[[NSString alloc] initWithFormat:message arguments:args] autorelease];
    va_end(args);
    const char *msg_c = [msg UTF8String];
    
    // create the system log message
    aslmsg msg_asl = asl_new(ASL_TYPE_MSG);
    asl_set(msg_asl, ASL_KEY_FACILITY, _lcl_component_header[component]);
    asl_set(msg_asl, ASL_KEY_LEVEL, _LCLSystemLog_aslLogLevel[level]);
    asl_set(msg_asl, "Level0", _lcl_level_header_1[level]);
    asl_set(msg_asl, ASL_KEY_MSG, msg_c);
    asl_set(msg_asl, "Thread", tid_c);
    asl_set(msg_asl, "File", file_c);
    asl_set(msg_asl, "Line", line_c);
    
    // send the system log message
    [_LCLSystemLog_aslClientLock lock];
    {
        asl_send(_LCLSystemLog_aslClient, msg_asl);
    }
    [_LCLSystemLog_aslClientLock unlock];
    
    // free the system log message
    asl_free(msg_asl);
    
    [pool release];
}

@end

