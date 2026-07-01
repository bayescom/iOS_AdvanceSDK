//
//  NSMutableDictionary+Mercury.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "NSMutableDictionary+Adv.h"

@implementation NSMutableDictionary (Adv)

- (void)adv_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if(!aKey) {
        return;
    }
    if(anObject) {
        [self setObject:anObject forKey:aKey];
    }
}

@end

