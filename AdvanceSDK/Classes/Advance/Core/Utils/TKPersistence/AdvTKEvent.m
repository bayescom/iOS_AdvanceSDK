#import "AdvTKEvent.h"
#import <math.h>

@implementation AdvTKEvent

+ (BOOL)isValidURLString:(NSString *)url {
    if (![url isKindOfClass:NSString.class] || !url.length ||
        [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 16 * 1024) {
        return NO;
    }
    NSURL *value = [NSURL URLWithString:url];
    NSString *scheme = value.scheme.lowercaseString;
    return value.host.length && ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]);
}

+ (instancetype)eventWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:NSDictionary.class]) return nil;
    for (NSString *key in @[@"taskId", @"appId", @"url"]) {
        if (![dictionary[key] isKindOfClass:NSString.class]) return nil;
    }
    for (NSString *key in @[@"eventType", @"createdAt", @"expiresAt", @"nextRetryAt", @"attemptCount"]) {
        NSNumber *number = dictionary[key];
        if (![number isKindOfClass:NSNumber.class] || !isfinite(number.doubleValue) || number.doubleValue < 0) return nil;
    }
    if (![dictionary[@"taskId"] length] || ![self isValidURLString:dictionary[@"url"]] ||
        [dictionary[@"eventType"] unsignedIntegerValue] > AdvSupplierReportTKEventBidWin ||
        [dictionary[@"attemptCount"] doubleValue] > UINT32_MAX ||
        [dictionary[@"expiresAt"] doubleValue] < [dictionary[@"createdAt"] doubleValue]) return nil;

    AdvTKEvent *event = [self new];
    event.taskId = dictionary[@"taskId"];
    event.appId = dictionary[@"appId"];
    event.url = dictionary[@"url"];
    event.eventType = [dictionary[@"eventType"] unsignedIntegerValue];
    event.createdAt = [dictionary[@"createdAt"] doubleValue];
    event.expiresAt = [dictionary[@"expiresAt"] doubleValue];
    event.nextRetryAt = [dictionary[@"nextRetryAt"] doubleValue];
    event.attemptCount = [dictionary[@"attemptCount"] unsignedIntegerValue];
    return event;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{@"taskId": self.taskId, @"appId": self.appId, @"url": self.url,
             @"eventType": @(self.eventType), @"createdAt": @(self.createdAt),
             @"expiresAt": @(self.expiresAt), @"nextRetryAt": @(self.nextRetryAt),
             @"attemptCount": @(self.attemptCount)};
}

- (id)copyWithZone:(NSZone *)zone {
    return [AdvTKEvent eventWithDictionary:self.dictionaryRepresentation];
}

@end
