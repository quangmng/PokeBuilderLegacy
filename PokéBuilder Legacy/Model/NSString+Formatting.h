//
//  NSString+Formatting.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 8/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

// The syntax for a Category is @interface ClassName (CategoryName)
@interface NSString (Formatting)

- (NSString *)readableFormat;
- (NSString *)apiPokemonFormat;
- (NSString *)apiGenericFormat;

@end
