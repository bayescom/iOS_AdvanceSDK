#import <Foundation/Foundation.h>
@protocol AdvAnalyticsProvider <NSObject>
- (void)trackAdvEvent:(NSString *)event withParameters:(NSDictionary *)parameters;
@end
