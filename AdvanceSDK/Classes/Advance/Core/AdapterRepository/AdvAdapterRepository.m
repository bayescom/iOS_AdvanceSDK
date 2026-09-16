#import "AdvAdapterRepository.h"
#import "AdvConstantHeader.h"
#import "AdvCustomAdnModel.h"

@interface AdvAdapterRepository ()
// 整表替换，读取时不会看到合并到一半的渠道数据。
@property (atomic, copy) NSDictionary<NSString *, AdvAdapterDescriptor *> *descriptorsById;
@end

@implementation AdvAdapterRepository

+ (instancetype)sharedInstance {
    static AdvAdapterRepository *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSDictionary<NSString *, AdvAdapterDescriptor *> *)builtInDescriptors {
    static NSDictionary<NSString *, AdvAdapterDescriptor *> *builtInDescriptors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 内置渠道集中在此声明；未集成的类解析为 Nil，不影响其他渠道。
        NSArray<AdvAdapterDescriptor *> *descriptors = @[
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_MERCURY
                                             configClassName:@"AdvMercuryConfigAdapter"
                                             splashClassName:@"AdvMercurySplashAdapter"
                                             bannerClassName:@"AdvMercuryBannerAdapter"
                                       interstitialClassName:@"AdvMercuryInterstitialAdapter"
                                        rewardVideoClassName:@"AdvMercuryRewardVideoAdapter"
                                    fullScreenVideoClassName:nil
                                      nativeExpressClassName:@"AdvMercuryNativeExpressAdapter"
                                         renderFeedClassName:@"AdvMercuryRenderFeedAdapter"
                                         versionParameterKey:@"mry_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_GDT
                                             configClassName:@"AdvGDTConfigAdapter"
                                             splashClassName:@"AdvGDTSplashAdapter"
                                             bannerClassName:@"AdvGDTBannerAdapter"
                                       interstitialClassName:@"AdvGDTInterstitialAdapter"
                                        rewardVideoClassName:@"AdvGDTRewardVideoAdapter"
                                    fullScreenVideoClassName:@"AdvGDTFullScreenVideoAdapter"
                                      nativeExpressClassName:@"AdvGDTNativeExpressAdapter"
                                         renderFeedClassName:@"AdvGDTRenderFeedAdapter"
                                         versionParameterKey:@"gdt_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_CSJ
                                             configClassName:@"AdvCSJConfigAdapter"
                                             splashClassName:@"AdvCSJSplashAdapter"
                                             bannerClassName:@"AdvCSJBannerAdapter"
                                       interstitialClassName:@"AdvCSJInterstitialAdapter"
                                        rewardVideoClassName:@"AdvCSJRewardVideoAdapter"
                                    fullScreenVideoClassName:@"AdvCSJFullScreenVideoAdapter"
                                      nativeExpressClassName:@"AdvCSJNativeExpressAdapter"
                                         renderFeedClassName:@"AdvCSJRenderFeedAdapter"
                                         versionParameterKey:@"csj_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_BAIDU
                                             configClassName:@"AdvBaiduConfigAdapter"
                                             splashClassName:@"AdvBaiduSplashAdapter"
                                             bannerClassName:nil
                                       interstitialClassName:@"AdvBaiduInterstitialAdapter"
                                        rewardVideoClassName:@"AdvBaiduRewardVideoAdapter"
                                    fullScreenVideoClassName:@"AdvBaiduFullScreenVideoAdapter"
                                      nativeExpressClassName:@"AdvBaiduNativeExpressAdapter"
                                         renderFeedClassName:@"AdvBaiduRenderFeedAdapter"
                                         versionParameterKey:@"bd_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_KS
                                             configClassName:@"AdvKSConfigAdapter"
                                             splashClassName:@"AdvKSSplashAdapter"
                                             bannerClassName:nil
                                       interstitialClassName:@"AdvKSInterstitialAdapter"
                                        rewardVideoClassName:@"AdvKSRewardVideoAdapter"
                                    fullScreenVideoClassName:@"AdvKSFullScreenVideoAdapter"
                                      nativeExpressClassName:@"AdvKSNativeExpressAdapter"
                                         renderFeedClassName:@"AdvKSRenderFeedAdapter"
                                         versionParameterKey:@"ks_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_TANX
                                             configClassName:@"AdvTanxConfigAdapter"
                                             splashClassName:@"AdvTanxSplashAdapter"
                                             bannerClassName:nil
                                       interstitialClassName:@"AdvTanxInterstitialAdapter"
                                        rewardVideoClassName:@"AdvTanxRewardVideoAdapter"
                                    fullScreenVideoClassName:nil
                                      nativeExpressClassName:@"AdvTanxNativeExpressAdapter"
                                         renderFeedClassName:@"AdvTanxRenderFeedAdapter"
                                         versionParameterKey:@"tanx_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_Sigmob
                                             configClassName:@"AdvSigmobConfigAdapter"
                                             splashClassName:@"AdvSigmobSplashAdapter"
                                             bannerClassName:nil
                                       interstitialClassName:@"AdvSigmobInterstitialAdapter"
                                        rewardVideoClassName:@"AdvSigmobRewardVideoAdapter"
                                    fullScreenVideoClassName:nil
                                      nativeExpressClassName:nil
                                         renderFeedClassName:@"AdvSigmobRenderFeedAdapter"
                                         versionParameterKey:@"sig_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_Funlink
                                             configClassName:@"AdvFunlinkConfigAdapter"
                                             splashClassName:@"AdvFunlinkSplashAdapter"
                                             bannerClassName:@"AdvFunlinkBannerAdapter"
                                       interstitialClassName:@"AdvFunlinkInterstitialAdapter"
                                        rewardVideoClassName:@"AdvFunlinkRewardVideoAdapter"
                                    fullScreenVideoClassName:nil
                                      nativeExpressClassName:@"AdvFunlinkNativeExpressAdapter"
                                         renderFeedClassName:@"AdvFunlinkRenderFeedAdapter"
                                         versionParameterKey:@"flink_v"],
            [[AdvAdapterDescriptor alloc] initWithSupplierId:SDK_ID_Noah
                                             configClassName:@"AdvNoahConfigAdapter"
                                             splashClassName:@"AdvNoahSplashAdapter"
                                             bannerClassName:nil
                                       interstitialClassName:@"AdvNoahInterstitialAdapter"
                                        rewardVideoClassName:@"AdvNoahRewardVideoAdapter"
                                    fullScreenVideoClassName:nil
                                      nativeExpressClassName:@"AdvNoahNativeExpressAdapter"
                                         renderFeedClassName:@"AdvNoahRenderFeedAdapter"
                                         versionParameterKey:@"hc_v"]
        ];
        NSMutableDictionary *table = [NSMutableDictionary dictionary];
        for (AdvAdapterDescriptor *descriptor in descriptors) {
            table[descriptor.supplierId] = descriptor;
        }
        builtInDescriptors = [table copy];
    });
    return builtInDescriptors;
}

- (void)loadBuiltInAdapterDescriptors {
    self.descriptorsById = [self.class builtInDescriptors];
}

- (void)syncCustomAdaptersWithAdnList:(NSArray<AdvCustomAdnModel *> *)adnList {
    // 每次以内置表为基础合并全量 custom_adn，移除已被后台删除的自定义渠道。
    NSMutableDictionary *table = [[self.class builtInDescriptors] mutableCopy];
    for (AdvCustomAdnModel *adn in adnList) {
        if (!adn.adnId.length || table[adn.adnId]) {
            continue;
        }
        table[adn.adnId] = [[AdvAdapterDescriptor alloc] initWithSupplierId:adn.adnId
                                                            configClassName:adn.customConfigAdapterClassName
                                                            splashClassName:adn.customSplashAdapterClassName
                                                            bannerClassName:adn.customBannerAdapterClassName
                                                      interstitialClassName:adn.customInterstitialAdapterClassName
                                                       rewardVideoClassName:adn.customRewardVideoAdapterClassName
                                                   fullScreenVideoClassName:nil
                                                     nativeExpressClassName:adn.customNativeExpressAdapterClassName
                                                        renderFeedClassName:adn.customRenderFeedAdapterClassName
                                                        versionParameterKey:[NSString stringWithFormat:@"custom_%@_v", adn.adnId]];
    }
    self.descriptorsById = table;
}

- (AdvAdapterDescriptor *)descriptorForSupplierId:(NSString *)supplierId {
    return supplierId.length ? self.descriptorsById[supplierId] : nil;
}

- (NSArray<AdvAdapterDescriptor *> *)allDescriptors {
    return self.descriptorsById.allValues ?: @[];
}

@end
