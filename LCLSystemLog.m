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

#import "LCLSystemLog.h"

#include <asl.h>
#include <mach/mach_init.h>


//
// Configuration checks.
//


#ifndef _LCLSystemLog_MirrorMessagesToStdErr
#error  '_LCLSystemLog_MirrorMessagesToStdErr' must be defined in 'lcl_config_logger.h'
#endif


//
// Fields.
//


// A lock which is held when the asl client connection is used.
static NSRecursiveLock *_LCLSystemLog_aslClientLock = nil;

// The asl client connection to use.
static aslclient _LCLSystemLog_aslClient = NULL;

// Log levels known by asl, indexed by ASL log level.
static const char * const _LCLSystemLog_aslLogLevelASL[] = {
    ASL_STRING_EMERG,   // Emergency
    ASL_STRING_ALERT,   // Alert
    ASL_STRING_CRIT,    // Critical
    ASL_STRING_ERR,     // Error
    ASL_STRING_WARNING, // Warning
    ASL_STRING_NOTICE,  // Notice
    ASL_STRING_INFO,    // Info
    ASL_STRING_DEBUG    // Debug
};

// Level0 headers, indexed by ASL log level.
static const char * const _LCLSystemLog_level0ASL[] = {
    "Y",                // Emergency
    "A",                // Alert
    "C",                // Critical
    "E",                // Error
    "W",                // Warning
    "N",                // Notice
    "I",                // Info
    "D"                 // Debug
};

// Log levels known by asl, indexed by LCL log level.
static const uint32_t _LCLSystemLog_aslLogLevelLCL[] = {
    ASL_LEVEL_DEBUG,    // Off
    ASL_LEVEL_CRIT,     // Critical
    ASL_LEVEL_ERR,      // Error
    ASL_LEVEL_WARNING,  // Warning
    ASL_LEVEL_NOTICE,   // Info
    ASL_LEVEL_DEBUG,    // Debug
    ASL_LEVEL_DEBUG     // Trace
};

// Level0 headers, indexed by LCL log level.
static const char * const _LCLSystemLog_level0LCL[] = {
    "-",                // Off
    "C",                // Critical
    "E",                // Error
    "W",                // Warning
    "I",                // Info
    "D",                // Debug
    "T"                 // Trace
};


@implementation LCLSystemLog


//
// Initialization.
//


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


//
// Logging methods.
//


// Writes the given log message to the log file (internal).
static void _LCLSystemLog_log(const char *identifier_c,
                              uint32_t level, const char *level0_c,
                              const char *path_c, uint32_t line,
                              const char *message_c) {
    // get file name from path
    const char *file_c = strrchr(path_c, '/');
    file_c = (file_c != NULL) ? (file_c + 1) : NULL;
    
    // get line
    char line_c[11];
    snprintf(line_c, sizeof(line_c), "%u", line);
    line_c[sizeof(line_c) - 1] = '\0';
    
    // get the ASL log level string, default is DEBUG
    const char *level_asl_c = ASL_STRING_DEBUG;
    if (level < sizeof(_LCLSystemLog_aslLogLevelASL)/sizeof(const char *)) {
        // a known ASL level
        level_asl_c = _LCLSystemLog_aslLogLevelASL[level];
    }
    
    // get the level0 header
    char level0_ca[11];
    if (level0_c == NULL) {
        if (level < sizeof(_LCLSystemLog_level0ASL)/sizeof(const char *)) {
            // a known level
            level0_c = _LCLSystemLog_level0ASL[level];
        } else {
            // unknown level, use the level number
            snprintf(level0_ca, sizeof(level0_ca), "%u", level);
            level0_c = level0_ca;
        }
    }
    
    
    // get thread id
    char tid_c[10];
    snprintf(tid_c, sizeof(tid_c), "%x", mach_thread_self());
    
    // create the system log message
    aslmsg message_asl = asl_new(ASL_TYPE_MSG);
    asl_set(message_asl, ASL_KEY_FACILITY, identifier_c);
    asl_set(message_asl, ASL_KEY_LEVEL, level_asl_c);
    asl_set(message_asl, ASL_KEY_MSG, message_c);
    asl_set(message_asl, "Level0", level0_c);
    asl_set(message_asl, "Thread", tid_c);
    asl_set(message_asl, "File", file_c);
    asl_set(message_asl, "Line", line_c);
    
    // send the system log message
    [_LCLSystemLog_aslClientLock lock];
    {
        asl_send(_LCLSystemLog_aslClient, message_asl);
    }
    [_LCLSystemLog_aslClientLock unlock];
    
    // free the system log message
    asl_free(message_asl);
}

// Writes the given log message to the log file (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier_c level:(uint32_t)level
                     path:(const char *)path_c line:(uint32_t)line
                   format:(NSString *)format, ... {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    va_list args;
    va_start(args, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    va_end(args);
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, level, NULL, path_c, line, message_c);
    
    // release local objects
    [pool release];
}


//
// Logging methods with log level mappings for LibComponentLogging.
//


// Writes the given log message to the log file (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier_c lclLevel:(uint32_t)lclLevel
                     path:(const char *)path_c line:(uint32_t)line
                   format:(NSString *)format, ... {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // map the LCL log level to a suitable ASL log level, default is DEBUG
    int level = ASL_LEVEL_DEBUG;
    char level0_ca[11];
    const char *level0_c;
    if (lclLevel < sizeof(_LCLSystemLog_aslLogLevelLCL)/sizeof(int32_t)) {
        // a known LCL level
        level = _LCLSystemLog_aslLogLevelLCL[lclLevel];
        level0_c = _LCLSystemLog_level0LCL[lclLevel];
    } else {
        // unknown level, use the level number
        snprintf(level0_ca, sizeof(level0_ca), "%u", lclLevel);
        level0_c = level0_ca;
    }
    
    // create log message
    va_list args;
    va_start(args, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    va_end(args);
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, level, level0_c, path_c, line, message_c);
    
    // release local objects
    [pool release];
}

@end

