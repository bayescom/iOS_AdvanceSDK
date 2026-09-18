
#import "AdvanceSDKConfig.h"

@implementation AdvanceSDKConfig

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.adspot_configs = [aDecoder decodeObjectForKey:@"adspot_configs"];
    }
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.adspot_configs forKey:@"adspot_configs"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"adspot_configs" : [AdvanceAdspotConfig class],
    };
}

@end


@implementation AdvanceAdspotConfig

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.adspot_id = [aDecoder decodeObjectForKey:@"adspot_id"];
        self.req_interval = [aDecoder decodeIntegerForKey:@"req_interval"];
        self.req_limit = [aDecoder decodeIntegerForKey:@"req_limit"];
        self.imp_limit = [aDecoder decodeIntegerForKey:@"imp_limit"];
        self.click_limit = [aDecoder decodeIntegerForKey:@"click_limit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.adspot_id forKey:@"adspot_id"];
    [aCoder encodeInteger:self.req_interval forKey:@"req_interval"];
    [aCoder encodeInteger:self.req_limit forKey:@"req_limit"];
    [aCoder encodeInteger:self.imp_limit forKey:@"imp_limit"];
    [aCoder encodeInteger:self.click_limit forKey:@"click_limit"];
}

@end

