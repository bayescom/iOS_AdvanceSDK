#import <Foundation/Foundation.h>
#import "AdvAnalyticsProvider.h"
#import "AdvAnalyticsConstants.h"

@interface AdvAnalytics : NSObject
@property (nonatomic, assign) id<AdvAnalyticsProvider> provider;
+ (instancetype)shared;
- (void)configure:(NSDictionary *)configurationDictionary provider:(id<AdvAnalyticsProvider>)provider;
@end
