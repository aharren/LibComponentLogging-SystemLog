//
//
// ASLDataStore.h
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

#import <Foundation/Foundation.h>


// A message in the ASL data store.
@interface ASLMessage : NSObject {
    
@protected
    NSMutableDictionary *valuesByKey;
    
}

- (NSString *)valueForKey:(NSString *)key;

@end


// An array of ASL messages.
@interface ASLMessageArray : NSObject {
    
@protected
    NSMutableArray *messages;
    
}

- (NSUInteger)count;
- (ASLMessage *)messageAtIndex:(NSUInteger)index;

@end


// A mark which represents a specific reference point in the ASL data store.
@interface ASLReferenceMark : NSObject {
    
@protected
    NSString *uuid;
    NSString *identifier;
    
}

- (NSString *)uuid;
- (NSString *)identifier;

@end


// The ASL data store.
@interface ASLDataStore : NSObject {
    
}

+ (ASLMessageArray *)messagesSinceReferenceMark:(ASLReferenceMark *)mark;

@end

