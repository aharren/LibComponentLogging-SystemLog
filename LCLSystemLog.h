//
//
// LCLSystemLog.h
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

#define _LCLSYSTEMLOG_VERSION_MAJOR  1
#define _LCLSYSTEMLOG_VERSION_MINOR  1
#define _LCLSYSTEMLOG_VERSION_BUILD  0
#define _LCLSYSTEMLOG_VERSION_SUFFIX "-devel"


//
// LCLSystemLog
//
// LCLSystemLog is a logging back-end implementation which sends log messages
// to the Apple System Log facility (ASL) (see man pages of asl, syslog, and
// syslogd for details). LCLSystemLog can be used as a logging back-end for
// LibComponentLogging, but it is also useable as a standalone logging class
// without the Core files of LibComponentLogging.
//
// With ASL, log messages are stored as structured messages in a data store.
// The syslog utility or the Console application can be used to retrieve
// messages from this data store, e.g.
//
//   syslog -F '$(Time) $(Sender)[$(PID):$(Thread)] $(Level0) $(Message) ($(Facility):$(File):$(Line))' -T utc -k Level0 -k Sender eq Example
//
// retrieves all messages from the data store where the value associated with
// the 'Sender' key (the identifier of an application) is equal to 'Example' and
// where a value for the 'Level0' key exists. The key 'Level0' is used by
// LCLSystemLog to store the log level in addition to a mapped ASL priority
// level ('Level' key). All retrieved messages will be printed by using the UTC
// time format and the display format specified via -F. Example output:
//
//   2009.02.21 11:37:08 UTC Example[6717:10b] D Message 1 (example.f1:main.m:28)
//   2009.02.21 11:37:08 UTC Example[6717:10b] C Message 2 (example.f2:main.m:32)
//   2009.02.21 11:37:08 UTC Example[6717:10b] I Message 3 (example.f3:main.m:36)
//
// By default, the default data store will only save log messages which have
// an ASL priority level between 'Emergency' and 'Notice' (level 0 to 5). Log
// messages with level 'Info' (level 6) or 'Debug' (level 7) will not be written
// to the data store. The command line
//
//   sudo syslog -c syslog -d
//
// can be used to tell syslogd to store messages up to priority level 'Debug'.
//
//
// LCLSystemLog is configured via the following #defines in LCLSystemLogConfig.h
// (see #import below):
//
// - Mirror log messages to stderr? (type BOOL)
//   #define _LCLSystemLog_MirrorMessagesToStdErr <definition>
//
// - Create ASL connections for each thread? (type BOOL)
//   #define _LCLSystemLog_UsePerThreadConnections <definition>
//
// - Show file names in the log messages? (type BOOL)
//   #define _LCLSystemLog_ShowFileNames <definition>
//
// - Show line numbers in the log messages? (type BOOL)
//   #define _LCLSystemLog_ShowLineNumbers <definition>
//
// - Show function names in the log messages? (type BOOL)
//   #define _LCLSystemLog_ShowFunctionNames <definition>
//
// - The last ASL log level to use, e.g. ASL_LEVEL_NOTICE. (type uint32_t)
//   #define _LCLSystemLog_LastASLLogLevelToUse <definition>
//
//
// When using LCLSystemLog as a back-end for LibComponentLogging, simply add an
//   #import "LCLSystemLog.h"
// statement to your lcl_config_logger.h file and use the LCLSystemLogConfig.h
// file for detailed configuration of the LCLSystemLog class.
//
// Please use a 'Reverse ICANN' naming scheme for log component headers as
// suggested by the ASL documentation.
//


#import <Foundation/Foundation.h>
#import "LCLSystemLogConfig.h"


@interface LCLSystemLog : NSObject {
    
}


//
// Logging methods.
//


// Writes the given log message to the system log.
+ (void)logWithIdentifier:(const char *)identifier level:(uint32_t)level
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                  message:(NSString *)message;

// Writes the given log message to the system log (format and va_list var args).
+ (void)logWithIdentifier:(const char *)identifier level:(uint32_t)level
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                   format:(NSString *)format args:(va_list)args;

// Writes the given log message to the system log (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier level:(uint32_t)level
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                   format:(NSString *)format, ... __attribute__((format(__NSString__, 6, 7)));


//
// Logging methods with log level mappings for LibComponentLogging.
//


// Writes the given log message to the system log.
+ (void)logWithIdentifier:(const char *)identifier lclLevel:(uint32_t)lclLevel
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                  message:(NSString *)message;

// Writes the given log message to the system log (format and va_list var args).
+ (void)logWithIdentifier:(const char *)identifier lclLevel:(uint32_t)lclLevel
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                   format:(NSString *)format args:(va_list)args;

// Writes the given log message to the system log (format and ... var args).
+ (void)logWithIdentifier:(const char *)identifier lclLevel:(uint32_t)lclLevel
                     path:(const char *)path line:(uint32_t)line
                 function:(const char *)function
                   format:(NSString *)format, ... __attribute__((format(__NSString__, 6, 7)));


//
// Configuration.
//


// Returns whether log messages are mirrored to stderr.
+ (BOOL)mirrorsToStdErr;

// Returns whether ASL connections are created for each thread.
+ (BOOL)usesPerThreadConnections;

// Returns whether file names are shown.
+ (BOOL)showsFileNames;

// Returns whether line numbers are shown.
+ (BOOL)showsLineNumbers;

// Returns whether function names are shown.
+ (BOOL)showsFunctionNames;

// Returns the last ASL log level to use for logging.
+ (uint32_t)lastASLLogLevelToUse;


@end


//
// Integration with LibComponentLogging Core.
//


// Define the _lcl_logger macro which integrates LCLSystemLog as a logging
// back-end for LibComponentLogging and pass the header of a log component as
// the identifier to LCLSystemLog's log method.
#define _lcl_logger(_component, _level, _format, ...) {                        \
    NSAutoreleasePool *_lcl_logger_pool = [[NSAutoreleasePool alloc] init];    \
    [LCLSystemLog logWithIdentifier:_lcl_component_header[_component]          \
                           lclLevel:_level                                     \
                               path:__FILE__                                   \
                               line:__LINE__                                   \
                           function:__FUNCTION__                               \
                             format:_format,                                   \
                                 ## __VA_ARGS__];                              \
    [_lcl_logger_pool release];                                                \
}

