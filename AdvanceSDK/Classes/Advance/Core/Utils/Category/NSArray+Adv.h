#import <Foundation/Foundation.h>

@interface NSArray (Adv)

- (NSArray *)adv_map:(id(^)(id))handle;
- (NSArray *)adv_filter:(BOOL(^)(id))handle;
- (id)adv_reduce:(id(^)(id, id))handle initial:(id)initial;

@end
