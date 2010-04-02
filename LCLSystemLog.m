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


#ifndef LCLSystemLog
#error  'LCLSystemLog' must be defined in LCLSystemLogConfig.h
#endif

#ifndef LCLSystemLogConnection
#error  'LCLSystemLogConnection' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_MirrorMessagesToStdErr
#error  '_LCLSystemLog_MirrorMessagesToStdErr' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_UsePerThreadConnections
#error  '_LCLSystemLog_UsePerThreadConnections' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_ShowFileNames
#error  '_LCLSystemLog_ShowFileNames' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_ShowLineNumbers
#error  '_LCLSystemLog_ShowLineNumbers' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_ShowFunctionNames
#error  '_LCLSystemLog_ShowFunctionNames' must be defined in LCLSystemLogConfig.h
#endif

#ifndef _LCLSystemLog_LastASLLogLevelToUse
#error  '_LCLSystemLog_LastASLLogLevelToUse' must be defined in LCLSystemLogConfig.h
#endif


//
// Fields.
//


// A lock which is held when the global ASL client connection is used.
static NSLock *_LCLSystemLog_globalAslClientLock = nil;

// The global ASL client connection.
static aslclient _LCLSystemLog_globalAslClient = NULL;

// YES, if log messages should be mirrored to stderr.
static BOOL _LCLSystemLog_mirrorToStdErr = NO;

// YES, if an ASL connection should be created for every thread.
static BOOL _LCLSystemLog_useThreadLocalConnections = NO;

// YES, if the file name should be shown.
static BOOL _LCLSystemLog_showFileName = NO;

// YES, if the line number should be shown.
static BOOL _LCLSystemLog_showLineNumber = NO;

// YES, if the function name should be shown.
static BOOL _LCLSystemLog_showFunctionName = NO;

// The last ASL log level to use, e.g. ASL_LEVEL_NOTICE.
static uint32_t _LCLSystemLog_lastUseableASLLogLevel = ASL_LEVEL_DEBUG;

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
static uint32_t const _LCLSystemLog_aslLogLevelLCL[] = {
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


//
// Holder for a per-thread connection.
//


@interface LCLSystemLogConnection : NSObject {
    
@private
    aslclient aslClient;
    
}

- (aslclient)aslClient;
- (void)setAslClient:(aslclient)client;

@end

@implementation LCLSystemLogConnection

- (aslclient)aslClient {
    return aslClient;
}

- (void)setAslClient:(aslclient)client {
    if (aslClient) {
        [LCLSystemLogConnection doesNotRecognizeSelector:_cmd];
    }
    aslClient = client;
}

- (void)dealloc {
    asl_close(aslClient);
    [super dealloc];
}

- (void)finalize {
    asl_close(aslClient);
    [super finalize];
}

@end


@implementation LCLSystemLog


//
// Initialization.
//


// Creates a new ASL connection.
static aslclient _LCLSystemLog_createAslConnection() {
    uint32_t client_opts = 0;
    if (_LCLSystemLog_mirrorToStdErr) {
        // mirror log messages to stderr if requested
        client_opts |= ASL_OPT_STDERR;
    }
    
    // open the asl client connection
    aslclient client = asl_open(NULL, NULL, client_opts);
    
    // log all messages up to DEBUG
    if (client) {
        asl_set_filter(client, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    }
    
    return client;
}

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
    
    // get whether we should mirror log messages to stderr
    _LCLSystemLog_mirrorToStdErr = (_LCLSystemLog_MirrorMessagesToStdErr);
    
    // get whether we should create an ASL connection for each thread
    _LCLSystemLog_useThreadLocalConnections = (_LCLSystemLog_UsePerThreadConnections);
    
    // create a global ASL connection if we are not using per-thread connections
    if (!_LCLSystemLog_useThreadLocalConnections) {
        // create a lock
        _LCLSystemLog_globalAslClientLock = [[NSLock alloc] init];
        
        // create the global ASL client connection
        _LCLSystemLog_globalAslClient = _LCLSystemLog_createAslConnection();
    }
    
    // get whether we should show file names
    _LCLSystemLog_showFileName = (_LCLSystemLog_ShowFileNames);
    
    // get whether we should show line numbers
    _LCLSystemLog_showLineNumber = (_LCLSystemLog_ShowLineNumbers);
    
    // get whether we should show function names
    _LCLSystemLog_showFunctionName = (_LCLSystemLog_ShowFunctionNames);
    
    // get the last ASL log level to use
    _LCLSystemLog_lastUseableASLLogLevel = (_LCLSystemLog_LastASLLogLevelToUse);
    if (_LCLSystemLog_lastUseableASLLogLevel > (uint32_t)ASL_LEVEL_DEBUG) {
        _LCLSystemLog_lastUseableASLLogLevel = (uint32_t)ASL_LEVEL_DEBUG;
    }
}


//
// Logging methods.
//


// Writes the given log message to the system log (internal).
static void _LCLSystemLog_log(const char *identifier_c,
                              uint32_t level, BOOL level_is_asl_level,
                              const char *path_c, uint32_t line,
                              const char *function_c,
                              const char *message_c) {
    // get settings
    const int show_file = _LCLSystemLog_showFileName;
    const int show_line = _LCLSystemLog_showLineNumber;
    const int show_function = _LCLSystemLog_showFunctionName;
    const uint32_t last_asl_level = _LCLSystemLog_lastUseableASLLogLevel;
    
    // get file name from path
    const char *file_c = NULL;
    if (show_file) {
        file_c = (path_c != NULL) ? strrchr(path_c, '/') : NULL;
        file_c = (file_c != NULL) ? (file_c + 1) : (path_c);
    }
    
    // get line
    char line_c[11];
    if (show_line) {
        snprintf(line_c, sizeof(line_c), "%u", line);
        line_c[sizeof(line_c) - 1] = '\0';
    }
    
    // get the ASL log level, default is DEBUG, and the level0 value
    uint32_t level_asl = ASL_LEVEL_DEBUG;
    const char *level0_c = NULL;
    if (level_is_asl_level) {
        if (level < sizeof(_LCLSystemLog_aslLogLevelASL)/sizeof(const char *)) {
            // a known ASL level
            level_asl = level;
            level0_c = _LCLSystemLog_level0ASL[level];
        }
    } else {
        // map the LCL log level to a suitable ASL log level, default is DEBUG
        if (level < sizeof(_LCLSystemLog_aslLogLevelLCL)/sizeof(uint32_t)) {
            // a known LCL level
            level_asl = _LCLSystemLog_aslLogLevelLCL[level];
            level0_c = _LCLSystemLog_level0LCL[level];
        }
    }
    
    // map the ASL log level to the last useable log level
    if (level_asl > last_asl_level) {
        level_asl = last_asl_level;
    }
    // get the ASL log level string
    const char *level_asl_c = _LCLSystemLog_aslLogLevelASL[level_asl];
    
    // create the level0 string if not already set
    char level0_ca[11];
    if (level0_c == NULL) {
        // unknown level, use the level number as level0
        snprintf(level0_ca, sizeof(level0_ca), "%u", level);
        level0_c = level0_ca;
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
    if (show_file) {
        asl_set(message_asl, "File", file_c);
    }
    if (show_line) {
        asl_set(message_asl, "Line", line_c);
    }
    if (show_function) {
        asl_set(message_asl, "Function", function_c);
    }
    
    // send the system log message
    if (_LCLSystemLog_useThreadLocalConnections) {
        // use a thread-local ASL connection
        aslclient client_asl = NULL;
        // look up the ASL connection in the thread dictionary
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
#       undef  as_NSString
#       define as_NSString( _text) as_NSString0(_text)
#       define as_NSString0(_text) @#_text
        LCLSystemLogConnection *connection = (LCLSystemLogConnection *)[threadDictionary objectForKey:as_NSString(LCLSystemLogConnection)];
        if (!connection) {
            // connection doesn't exist, create one and add it to the thread
            // dictionary; it will be destroyed when the thread dies
            connection = [[LCLSystemLogConnection alloc] init];
            if (connection) {
                client_asl = _LCLSystemLog_createAslConnection();
                [connection setAslClient:client_asl];
                [threadDictionary setObject:connection
                                     forKey:as_NSString(LCLSystemLogConnection)];
                [connection release];
            }
        } else {
            // use existing connection
            client_asl = [connection aslClient];
        }
#       undef  as_NSString
        asl_send(client_asl, message_asl);
    } else {
        // use the global ASL connection under lock protection
        [_LCLSystemLog_globalAslClientLock lock];
        {
            asl_send(_LCLSystemLog_globalAslClient, message_asl);
        }
        [_LCLSystemLog_globalAslClientLock unlock];
    }
    
    // free the system log message
    asl_free(message_asl);
}

// Writes the given log message to the system log.
+ (void)logWithIdentifier:(const char *)identifier_c level:(uint32_t)level
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                  message:(NSString *)message {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, level, YES, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}

// Writes the given log message to the system log (format and va_list var args).
+ (void)logWithIdentifier:(const char *)identifier_c level:(uint32_t)level
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                   format:(NSString *)format args:(va_list)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, level, YES, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}

// Writes the given log message to the system log (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier_c level:(uint32_t)level
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                   format:(NSString *)format, ... {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    va_list args;
    va_start(args, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    va_end(args);
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, level, YES, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}


//
// Logging methods with log level mappings for LibComponentLogging.
//


// Writes the given log message to the system log.
+ (void)logWithIdentifier:(const char *)identifier_c lclLevel:(uint32_t)lclLevel
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                  message:(NSString *)message {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, lclLevel, NO, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}

// Writes the given log message to the system log (format and va_list var args).
+ (void)logWithIdentifier:(const char *)identifier_c lclLevel:(uint32_t)lclLevel
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                   format:(NSString *)format args:(va_list)args {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, lclLevel, NO, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}

// Writes the given log message to the system log (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier_c lclLevel:(uint32_t)lclLevel
                     path:(const char *)path_c line:(uint32_t)line
                 function:(const char *)function_c
                   format:(NSString *)format, ... {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create log message
    va_list args;
    va_start(args, format);
    NSString *message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
    va_end(args);
    const char *message_c = [message UTF8String];
    
    // write log message
    _LCLSystemLog_log(identifier_c, lclLevel, NO, path_c, line, function_c, message_c);
    
    // release local objects
    [pool release];
}


//
// Configuration.
//


// Returns whether log messages are mirrored to stderr.
+ (BOOL)mirrorsToStdErr {
    return _LCLSystemLog_mirrorToStdErr;
}

// Returns whether ASL connections are created for each thread.
+ (BOOL)usesPerThreadConnections {
    return _LCLSystemLog_useThreadLocalConnections;
}

// Returns whether file names are shown.
+ (BOOL)showsFileNames {
    return _LCLSystemLog_showFileName;
}

// Returns whether line numbers are shown.
+ (BOOL)showsLineNumbers {
    return _LCLSystemLog_showLineNumber;
}

// Returns whether function names are shown.
+ (BOOL)showsFunctionNames {
    return _LCLSystemLog_showFunctionName;
}

// Returns the last ASL log level to use for logging.
+ (uint32_t)lastASLLogLevelToUse {
    return _LCLSystemLog_lastUseableASLLogLevel;
}


@end

