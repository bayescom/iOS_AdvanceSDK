#import <Foundation/Foundation.h>

@interface NSArray (Adv)

- (NSArray *)map:(id(^)(id))handle;
- (NSArray *)filter:(BOOL(^)(id))handle;
- (id)reduce:(id(^)(id, id))handle initial:(id)initial;

@end
