//
//
// ASLDataStore.m
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

#import "ASLDataStore.h"
#import <asl.h>
#import <unistd.h>


// ARC defines for non-ARC builds
#if !__has_feature(objc_arc)
#ifndef __bridge
#define __bridge
#endif
#endif

#ifndef _LCL_NO_IGNORE_WARNINGS
#   ifdef __clang__
    // Ignore some warnings about deprecated ivar access when using '-Weverything'.
#   pragma clang diagnostic push
#   pragma clang diagnostic ignored "-Wdirect-ivar-access"
#   endif
#endif

// A message in the ASL data store.
@implementation ASLMessage

- (id)initWithMessage:(aslmsg)message {
    if ((self = [super init])) {
        // convert the given ASL message into a map from keys to values
        valuesByKey = [[NSMutableDictionary alloc] init];
        
        const char *key = NULL;
        uint32_t idx = 0;
        while ((key = asl_key(message, idx++))) {
            const char *value = asl_get(message, key);
            if (value == NULL) {
                value = "(null)";
            }
            [valuesByKey setObject:[NSString stringWithUTF8String:value]
                            forKey:[NSString stringWithUTF8String:key]];
        }
    }
    return self;
}

- (void)dealloc {
#   if !__has_feature(objc_arc)
    [valuesByKey release];
    [super dealloc];
#   endif
}

- (NSString *)valueForKey:(NSString *)key {
    return (NSString *)[valuesByKey objectForKey:key];
}

@end


// An array of ASL messages.
@implementation ASLMessageArray

- (id)initWithResponse:(aslresponse)aslResponse upToMessage:(NSString *)lastMessage found:(BOOL *)found{
    if ((self = [super init])) {
        // convert the given ASL response into an array of messages
        messages = [[NSMutableArray alloc] init];
        *found = NO;
        
        aslmsg aslMessage = NULL;
        while ((aslMessage = aslresponse_next(aslResponse))) {
            ASLMessage *message = [[ASLMessage alloc] initWithMessage:aslMessage];
#           if !__has_feature(objc_arc)
            [message autorelease];
#           endif
            if ([[message valueForKey:@"Message"] isEqualToString:lastMessage]) {
                *found = YES;
                break;
            }
            
            if (![[message valueForKey:@"Message"] hasPrefix:@"tag"]) {
                [messages addObject:message];
            }
        }
    }
    return self;
}

- (void)dealloc {
#   if !__has_feature(objc_arc)
    [messages release];
    [super dealloc];
#   endif
}

- (NSUInteger)count {
    return [messages count];
}

- (ASLMessage *)messageAtIndex:(NSUInteger)idx {
    return (ASLMessage *)[messages objectAtIndex:idx];
}

@end


// A mark which represents a specific reference point in the ASL data store.
@implementation ASLReferenceMark

- (id)init {
    if ((self = [super init])) {
        // get a uuid
        CFUUIDRef cfuuid = CFUUIDCreate(nil);
        uuid = (__bridge NSString *)CFUUIDCreateString(nil, cfuuid);
        CFRelease(cfuuid);
        
        // create a tag with the uuid and the pid
        NSString *tag = [NSString stringWithFormat:@"tag begin %@ %u", uuid, getpid()];
        
        // log the tag and some dummy entries
        asl_log(NULL, NULL, 1, "%s", [tag UTF8String]);
        asl_log(NULL, NULL, 1, "tag begin a");
        asl_log(NULL, NULL, 1, "tag begin b");
        
        // create a query with the tag and the pid
        aslmsg query = asl_new(ASL_TYPE_QUERY);
        asl_set_query(query, ASL_KEY_MSG, [tag UTF8String], ASL_QUERY_OP_EQUAL);
        asl_set_query(query, "PID", [[NSString stringWithFormat:@"%u", getpid()] UTF8String], ASL_QUERY_OP_EQUAL);
        
        // query the data store and keep the message id as an identifier
        uint32_t iteration = 1;
        do {
            aslresponse aslResponse = asl_search(NULL, query);
            aslmsg aslMessage = NULL;
            while ((aslMessage = aslresponse_next(aslResponse))) {
                const char *message = asl_get(aslMessage, "Message");
                if (message != NULL && strcmp(message, [tag UTF8String]) == 0) {
                    identifier = [[NSString alloc] initWithUTF8String:asl_get(aslMessage, "ASLMessageID")];
                }
            }
            aslresponse_free(aslResponse);
            
            if (identifier != nil) {
                // identifier is set, stop
                break;
            }
            
            // identifier is not set, retry
            asl_log(NULL, NULL, 1, "tag begin %u", iteration);
            iteration++;
            sleep(1);
        } while (true);
        
        asl_free(query);
    }
    return self;
}

- (void)dealloc {
#   if !__has_feature(objc_arc)
    [uuid release];
    [identifier release];
    [super dealloc];
#   endif
}

- (NSString *)uuid {
    return uuid;
}

- (NSString *)identifier {
    return identifier;
}

@end


// The ASL data store.
@implementation ASLDataStore

+ (ASLMessageArray *)messagesSinceReferenceMark:(ASLReferenceMark *)mark {
    // create a tag with the mark's uuid and the pid
    NSString *tag = [NSString stringWithFormat:@"tag end   %@ %u", [mark uuid], getpid()];
    
    // log the tag and some dummy entries
    asl_log(NULL, NULL, 1, "%s", [tag UTF8String]);
    asl_log(NULL, NULL, 1, "tag end a");
    asl_log(NULL, NULL, 1, "tag end b");
    
    // create a query with the mark's identifier (the message id) and the pid
    aslmsg query = asl_new(ASL_TYPE_QUERY);
    asl_set_query(query, "ASLMessageID", [[mark identifier] UTF8String], ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
    asl_set_query(query, "PID", [[NSString stringWithFormat:@"%u", getpid()] UTF8String], ASL_QUERY_OP_EQUAL);
    
    // query the data store and create messages
    ASLMessageArray *messages = nil;
    uint32_t iteration = 1;
    do {
        aslresponse response = asl_search(NULL, query);
        BOOL tagFound = NO;
        messages = [[ASLMessageArray alloc] initWithResponse:response upToMessage:tag found:&tagFound];
#       if !__has_feature(objc_arc)
        [messages autorelease];
#       endif
        aslresponse_free(response);
        
        if (tagFound) {
            // the tag exist, stop
            break;
        }
        
        // the tag wasn't there, retry
        asl_log(NULL, NULL, 1, "tag end %u", iteration);
        iteration++;
        sleep(1);
    } while (true);
    
    asl_free(query);
    
    return messages;
}

@end

#ifndef _LCL_NO_IGNORE_WARNINGS
#   ifdef __clang__
#   pragma clang diagnostic pop
#   endif
#endif

