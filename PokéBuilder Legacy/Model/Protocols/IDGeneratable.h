//
//  IDGeneratable.h
//  PokéBuilder Legacy
//
//  Created by Quang Minh Nguyen on 7/07/2026.
//  Copyright (c) 2026 Quang Minh Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

// (Comments taken from @TianLangHin's PokéCalc repo)

// This protocol defines the behaviour of classes that generate primary keys for storage in an SQLite database.
@protocol IDGeneratable <NSObject>
// The class itself must keep some internal counter and return a unique number
// in each successive call of this function.
+ (NSInteger)getUniqueId;
// The internal counter can be reset to either avoid a certain possibly-filled range,
// or instead to reset it back to a now-empty range.
+ (void)resetIdCounterToMaximum:(NSInteger)maximum;
@end
