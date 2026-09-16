#import "AdvanceBaseAdSpot.h"
#import "AdvLog.h"
#import "AdvPolicyService.h"
#import "AdvConstantHeader.h"
#import "AdvanceCommonConfigAdapter.h"
#import "AdvAdapterRepository.h"

@interface AdvanceBaseAdSpot () <AdvPolicyServiceDelegate>

@end

@implementation AdvanceBaseAdSpot

@synthesize adspotid = _adspotid;
@synthesize reqId = _reqId;
@synthesize extraDict = _extraDict;
@synthesize adapterMap = _adapterMap;
@synthesize targetAdapter = _targetAdapter;
@synthesize manager = _manager;
@synthesize suppliers = _suppliers;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    if (self = [super init]) {
        _adspotid = adspotid;
        _extraDict = [extra mutableCopy];
        _reqId = [AdvDeviceManager getUUID];
        _manager = [AdvPolicyService manager];
        ((AdvPolicyService *)_manager).delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
        _suppliers = [NSMutableArray array];
        [self setupAllSDKVersion];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadPolicyDataWithAdspotId:_adspotid reqId:_reqId extra:_extraDict.copy];
}

- (void)performAdapterLoadResultOnMainThread:(void (^)(void))block {
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)destroyAdapters {
    self.adapterMap = nil;
    self.manager = nil;
}

- (AdvanceAdInfo * _Nullable)getAdInfo { 
    return nil;
}


- (void)setupAllSDKVersion {
    for (AdvAdapterDescriptor *descriptor in [[AdvAdapterRepository sharedInstance] allDescriptors]) {
        Class<AdvanceCommonConfigAdapter> clazz = descriptor.configAdapterClass;
        if ([clazz respondsToSelector:@selector(sdkVersion)]) {
            NSString *version = [clazz sdkVersion];
            [_extraDict adv_safeSetObject:version forKey:descriptor.versionParameterKey];
        }
    }
}

- (void)dealloc {
    
}

@end
