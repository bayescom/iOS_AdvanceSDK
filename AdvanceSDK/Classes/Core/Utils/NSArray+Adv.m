#import "NSArray+Adv.h"

@implementation NSArray (Adv)

- (NSArray *)map:(id(^)(id))handle {
    if (!handle || !self) return self;
    
    NSMutableArray *arr = NSMutableArray.array;
    for (id obj in self) {
        id new = handle(obj);
        if (new) {
            [arr addObject:new];
        }
    }
    return arr.copy;
}

- (NSArray *)filter:(BOOL(^)(id))handle {
    if (!handle || !self) return self;
    
    NSMutableArray *arr = NSMutableArray.array;
    for (id obj in self) {
        if (handle(obj)) {
            [arr addObject:obj];
        }
    }
    return arr.copy;
}

- (id)reduce:(id(^)(id, id))handle initial:(id)initial {
    if (!handle || !self || !initial) return self;
    if (self.count < 1) return initial;
    
    id value = initial;
    for (id obj in self) {
        value = handle(value, obj);
    }
    return value;
}

@end
