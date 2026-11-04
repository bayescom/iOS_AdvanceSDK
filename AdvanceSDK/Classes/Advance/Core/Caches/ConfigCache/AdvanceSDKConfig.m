
#import "AdvanceSDKConfig.h"

@implementation AdvanceSDKConfig

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.adspot_configs = [aDecoder decodeObjectForKey:@"adspot_configs"];
        self.material_inspection_config = [aDecoder decodeObjectForKey:@"material_inspection_config"];
    }
    return self;
}
 
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.adspot_configs forKey:@"adspot_configs"];
    [aCoder encodeObject:self.material_inspection_config forKey:@"material_inspection_config"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"adspot_configs" : [AdvanceAdspotConfig class],
    };
}

@end


@implementation AdvMaterialInspectionConfig

- (instancetype)init {
    if (self = [super init]) {
        _exposure_sample_rate = 0.01;
        _capture_delay_ms = 1000;
        _image_max_size = 500;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [self init]) {
        if ([aDecoder containsValueForKey:@"enable"]) {
            self.enable = [aDecoder decodeIntegerForKey:@"enable"];
        }
        if ([aDecoder containsValueForKey:@"exposure_sample_rate"]) {
            self.exposure_sample_rate = [aDecoder decodeDoubleForKey:@"exposure_sample_rate"];
        }
        if ([aDecoder containsValueForKey:@"capture_delay_ms"]) {
            self.capture_delay_ms = [aDecoder decodeIntegerForKey:@"capture_delay_ms"];
        }
        if ([aDecoder containsValueForKey:@"image_max_size"]) {
            self.image_max_size = [aDecoder decodeIntegerForKey:@"image_max_size"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.enable forKey:@"enable"];
    [aCoder encodeDouble:self.exposure_sample_rate forKey:@"exposure_sample_rate"];
    [aCoder encodeInteger:self.capture_delay_ms forKey:@"capture_delay_ms"];
    [aCoder encodeInteger:self.image_max_size forKey:@"image_max_size"];
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
