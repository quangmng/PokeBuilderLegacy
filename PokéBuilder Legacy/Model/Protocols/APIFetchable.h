//
//  APIFetchable.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define a block (closure) signature to handle the asynchronous callback.
// Because there are no generics, to be using 'id' meaning "any Objective-C object"
// for the result, and pass an NSError pointer to handle failures safely.
typedef void (^APIFetchCompletion)(id result, NSError *error);

// Define the protocol itself, conforming to the base NSObject protocol.
@protocol APIFetchable <NSObject>

// The fetching method. Instead of `async` returning data, the method is `void`.
// It takes in parameters (using 'id' for NSString, NSDictionary, etc.)
// and takes the custom block to execute whenever the network request finally finishes.
- (void)fetchWithParameters:(id)parameters completion:(APIFetchCompletion)completion;

@end