//
//  AdvPolicyModel.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces


@implementation AdvPolicyModel

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.gro_more = [aDecoder decodeObjectForKey:@"gro_more"];
        self.server_reward = [aDecoder decodeObjectForKey:@"server_reward"];
        self.setting = [aDecoder decodeObjectForKey:@"setting"];
        self.suppliers = [[aDecoder decodeObjectForKey:@"suppliers"] mutableCopy];
        self.msg = [aDecoder decodeObjectForKey:@"msg"];
        self.code = [aDecoder decodeIntegerForKey:@"code"];
        self.reqid = [aDecoder decodeObjectForKey:@"reqid"];
        self.strategyCachedTimestamp = [aDecoder decodeDoubleForKey:@"strategyCachedTimestamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_gro_more forKey:@"gro_more"];
    [aCoder encodeObject:_server_reward forKey:@"server_reward"];
    [aCoder encodeObject:_setting forKey:@"setting"];
    [aCoder encodeObject:_suppliers forKey:@"suppliers"];
    [aCoder encodeObject:_msg forKey:@"msg"];
    [aCoder encodeInteger:_code forKey:@"code"];
    [aCoder encodeObject:_reqid forKey:@"reqid"];
    [aCoder encodeDouble:_strategyCachedTimestamp forKey:@"strategyCachedTimestamp"];
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"suppliers" : [AdvSupplier class]};
}

@end

@implementation AdvSupplier

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.sdktag = [aDecoder decodeObjectForKey:@"sdktag"];
        self.mediakey = [aDecoder decodeObjectForKey:@"mediakey"];
        self.mediaid = [aDecoder decodeObjectForKey:@"mediaid"];
        self.mediasecret = [aDecoder decodeObjectForKey:@"mediasecret"];
        self.priority = [aDecoder decodeIntegerForKey:@"priority"];
        self.timeout = [aDecoder decodeIntegerForKey:@"timeout"];
        self.adspotid = [aDecoder decodeObjectForKey:@"adspotid"];
        self.sdk_price = [aDecoder decodeIntegerForKey:@"sdk_price"];
        self.sdk_id = [aDecoder decodeObjectForKey:@"sdk_id"];
        self.enable_cache = [aDecoder decodeIntegerForKey:@"enable_cache"];
        self.cache_timeout = [aDecoder decodeIntegerForKey:@"cache_timeout"];
        self.is_head_bidding = [aDecoder decodeIntegerForKey:@"is_head_bidding"];
        self.bid_ratio = [aDecoder decodeDoubleForKey:@"bid_ratio"];
        self.clicktk = [aDecoder decodeObjectForKey:@"clicktk"];
        self.loadedtk = [aDecoder decodeObjectForKey:@"loadedtk"];
        self.loadendtk = [aDecoder decodeObjectForKey:@"loadendtk"];
        self.imptk = [aDecoder decodeObjectForKey:@"imptk"];
        self.succeedtk = [aDecoder decodeObjectForKey:@"succeedtk"];
        self.failedtk = [aDecoder decodeObjectForKey:@"failedtk"];
        self.wintk = [aDecoder decodeObjectForKey:@"wintk"];
        self.is_custom_adn = [aDecoder decodeIntegerForKey:@"is_custom_adn"];
        self.custom_params = [aDecoder decodeObjectForKey:@"custom_params"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_sdktag forKey:@"sdktag"];
    [aCoder encodeObject:_mediakey forKey:@"mediakey"];
    [aCoder encodeObject:_mediaid forKey:@"mediaid"];
    [aCoder encodeObject:_mediasecret forKey:@"mediasecret"];
    [aCoder encodeInteger:_priority forKey:@"priority"];
    [aCoder encodeInteger:_timeout forKey:@"timeout"];
    [aCoder encodeObject:_adspotid forKey:@"adspotid"];
    [aCoder encodeInteger:_sdk_price forKey:@"sdk_price"];
    [aCoder encodeObject:_sdk_id forKey:@"sdk_id"];
    [aCoder encodeInteger:_enable_cache forKey:@"enable_cache"];
    [aCoder encodeInteger:_cache_timeout forKey:@"cache_timeout"];
    [aCoder encodeInteger:_is_head_bidding forKey:@"is_head_bidding"];
    [aCoder encodeDouble:_bid_ratio forKey:@"bid_ratio"];
    [aCoder encodeObject:_clicktk forKey:@"clicktk"];
    [aCoder encodeObject:_loadedtk forKey:@"loadedtk"];
    [aCoder encodeObject:_loadendtk forKey:@"loadendtk"];
    [aCoder encodeObject:_imptk forKey:@"imptk"];
    [aCoder encodeObject:_succeedtk forKey:@"succeedtk"];
    [aCoder encodeObject:_failedtk forKey:@"failedtk"];
    [aCoder encodeObject:_wintk forKey:@"wintk"];
    [aCoder encodeInteger:_is_custom_adn forKey:@"is_custom_adn"];
    [aCoder encodeObject:_custom_params forKey:@"custom_params"];
}


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"identifier": @"id",
    };
}

- (NSInteger)timeout {
    if (!_timeout) {
        return 3000;
    }
    return _timeout;
}

- (NSInteger)cache_timeout {
    if (_enable_cache && !_cache_timeout) {
        return 1800;
    }
    return _cache_timeout;
}

- (AdvanceAdInfo *)transformAdnInfo {
    AdvanceAdInfo *adInfo = [[AdvanceAdInfo alloc] init];
    adInfo.adnId = self.identifier;
    adInfo.adnName = self.name;
    adInfo.appId = self.mediaid;
    adInfo.placementId = self.adspotid;
    adInfo.biddingType = self.is_head_bidding;
    adInfo.price = self.sdk_price;
    adInfo.fromCache = self.cachedReqId.length;
    return adInfo;
}

@end

@implementation AdvSetting

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.enable_strategy_cache = [aDecoder decodeIntegerForKey:@"enable_strategy_cache"];
        self.strategy_cache_duration = [aDecoder decodeIntegerForKey:@"strategy_cache_duration"];
        self.bidding_type = [aDecoder decodeIntegerForKey:@"bidding_type"];
        self.parallel_timeout = [aDecoder decodeIntegerForKey:@"parallel_timeout"];
        self.parallelGroup = [[aDecoder decodeObjectForKey:@"parallelGroup"] mutableCopy];
        self.headBiddingGroup = [[aDecoder decodeObjectForKey:@"headBiddingGroup"] mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_enable_strategy_cache forKey:@"enable_strategy_cache"];
    [aCoder encodeInteger:_strategy_cache_duration forKey:@"strategy_cache_duration"];
    [aCoder encodeInteger:_bidding_type forKey:@"bidding_type"];
    [aCoder encodeInteger:_parallel_timeout forKey:@"parallel_timeout"];
    [aCoder encodeObject:_parallelGroup forKey:@"parallelGroup"];
    [aCoder encodeObject:_headBiddingGroup forKey:@"headBiddingGroup"];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"parallelGroup": @"parallel_group",
        @"headBiddingGroup": @"head_bidding_group",
    };
}

- (NSInteger)parallel_timeout {
    if (!_parallel_timeout) {
        return 5000;
    }
    return _parallel_timeout;
}

- (NSInteger)strategy_cache_duration {
    if (!_strategy_cache_duration) {
        return 48 * 3600; // 策略缓存默认48小时
    }
    return _strategy_cache_duration;
}

@end

@implementation ServerReward

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.count = [aDecoder decodeIntegerForKey:@"count"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeInteger:_count forKey:@"count"];
}


@end


@implementation Gmtk

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.failedtk = [aDecoder decodeObjectForKey:@"failedtk"];
        self.imptk = [aDecoder decodeObjectForKey:@"imptk"];
        self.biddingtk = [aDecoder decodeObjectForKey:@"biddingtk"];
        self.succeedtk = [aDecoder decodeObjectForKey:@"succeedtk"];
        self.clicktk = [aDecoder decodeObjectForKey:@"clicktk"];
        self.loadedtk = [aDecoder decodeObjectForKey:@"loadedtk"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_failedtk forKey:@"failedtk"];
    [aCoder encodeObject:_imptk forKey:@"imptk"];
    [aCoder encodeObject:_biddingtk forKey:@"biddingtk"];
    [aCoder encodeObject:_succeedtk forKey:@"succeedtk"];
    [aCoder encodeObject:_clicktk forKey:@"clicktk"];
    [aCoder encodeObject:_loadedtk forKey:@"loadedtk"];
}


@end


@implementation Gromore_params

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.appid = [aDecoder decodeObjectForKey:@"appid"];
        self.adspotid = [aDecoder decodeObjectForKey:@"adspotid"];
        self.timeout = [aDecoder decodeIntegerForKey:@"timeout"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_appid forKey:@"appid"];
    [aCoder encodeObject:_adspotid forKey:@"adspotid"];
    [aCoder encodeInteger:_timeout forKey:@"timeout"];
}


@end


@implementation Gro_more 

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.gmtk = [aDecoder decodeObjectForKey:@"gmtk"];
        self.gromore_params = [aDecoder decodeObjectForKey:@"gromore_params"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_gmtk forKey:@"gmtk"];
    [aCoder encodeObject:_gromore_params forKey:@"gromore_params"];
}


@end


NS_ASSUME_NONNULL_END
