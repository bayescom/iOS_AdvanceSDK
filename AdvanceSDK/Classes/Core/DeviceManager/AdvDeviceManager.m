#import "AdvDeviceManager.h"
#include <sys/stat.h>
#include <sys/sysctl.h>
#import <sys/utsname.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonCrypto.h>
#import "AdvConstantHeader.h"
#import "AdvReachability.h"
#import "NSString+Adv.h"
#import "AdvanceAESCipher.h"

#define kExpireTimeForOneMonth      60 * 60 * 24 * 30 // 30天
#define kExpireTimeForOneHour       60 * 60 // 1小时

#define kInvariableDeviceInfoKey         @"kAdvInvariableDeviceInfoKey"
#define kIdfvExpiredKey                  @"kAdvIdfvExpiredKey"
#define kIdfvDataKey                     @"kAdvIdfvDataKey"
#define kIdfaExpiredKey                  @"kAdvIdfaExpiredKey"
#define kIdfaDataKey                     @"kAdvIdfaDataKey"
#define kCarrierExpiredKey               @"kAdvCarrierExpiredKey"
#define kCarrierDataKey                  @"kAdvCarrierDataKey"


@implementation AdvDeviceManager
// MARK: 单例
static AdvDeviceManager *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    if (self = [super init]) {
        _isAdTrack = YES;
    }
    return self;
}

// MARK: - Public
- (NSDictionary *)getDeviceInfoForAdRequest {
    
    NSMutableDictionary *secrectDeviceInfo = [self getInvariableDeviceInfo];
    // 网络连接类型, 0:未识别, 1:WIFI, 2:2G, 3:3G, 4:4G, 5:5G。
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getNetwork] forKey:@"network"];
    // 操作系统版本号
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getOsv] forKey:@"osv"];
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getDeviceType] forKey:@"devicetype"];
    // idfa
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getIdfa] forKey:@"idfa"];
    // idfv
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getIdfv] forKey:@"idfv"];
    // 运营商信息, 使用标准MCC/MNC码
    [secrectDeviceInfo adv_safeSetObject:[AdvDeviceManager getCarrier] forKey:@"carrier"];
    
    // 对上述字段加密
    NSString *dicString = [NSString adv_jsonStringWithDictionary:secrectDeviceInfo];
    AdvLog(@"mercuryplus 加密前 %@", dicString);
    NSString *secret = advanceAesEncryptString(dicString, AdvanceSDKSecretKey);
    NSString *result = [AdvDeviceManager base64UrlEncoder:secret];
    AdvLog(@"mercuryplus 加密后 %@", result);
    
    /// 接口参数包装字典
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 加密数据
    [params adv_safeSetObject:result forKey:@"device_encinfo"];
    // sdk version
    [params adv_safeSetObject:AdvanceSDKVersion forKey:@"sdk_version"];
    // 请求的unix时间戳,精确到毫秒(13位)
    NSString *time = [AdvDeviceManager getTime];
    [params adv_safeSetObject:time forKey:@"time"];
    // appid
    [params adv_safeSetObject:self.appId forKey:@"appid"];
    // APP的版本号
    [params adv_safeSetObject:[AdvDeviceManager getAppVersion] forKey:@"appver"];
    // 接口版本号
    [params adv_safeSetObject:AdvanceSDKAPIVersion forKey:@"version"];
    // adtrack
    [params adv_safeSetObject:self.isAdTrack ? @"0" : @"1" forKey:@"donottrack"];
    
    return [params copy];
}

/// 设置不变的设备数据
- (NSMutableDictionary *)getInvariableDeviceInfo {
    NSString *invariableDeviceInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kInvariableDeviceInfoKey];
    if (invariableDeviceInfo) {
        NSString *decodeString = advanceAesDecryptString(invariableDeviceInfo, AdvanceSDKSecretKey);
        return [NSString adv_dictionaryWithJsonString:decodeString].mutableCopy;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    // 操作系统类型,0:未识别, 1:ios, 2:android
    [dict adv_safeSetObject:@1 forKey:@"os"];
    // model
    [dict adv_safeSetObject:[AdvDeviceManager getModel] forKey:@"model"];
    // make
    [dict adv_safeSetObject:[AdvDeviceManager getMake] forKey:@"make"];
    
    // 加密字段
    NSString *dicString = [NSString adv_jsonStringWithDictionary:dict];
    
    [AdvDeviceManager saveEncodedString:dicString key:kInvariableDeviceInfoKey];
    
    return dict;
}

/// 因为Base64编码中包含有+,/,=这些不安全的URL字符串，所以要进行换字符
+ (NSString *)base64UrlEncoder:(NSString *)str {
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return str;
}

/// 将Base64编码中的"-"，"_"字符串转换成"+"，"/"，字符串长度余4倍的位补"="
+ (NSString *)base64UrlDecoder:(NSString *)str {
    NSMutableString *base64Str = [[NSMutableString alloc] initWithString:str];
    base64Str = (NSMutableString * )[base64Str stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64Str = (NSMutableString * )[base64Str stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSInteger mod4 = base64Str.length % 4;
    if (mod4) {
        [base64Str appendString:[@"====" substringToIndex:(4 - mod4)]];
    }
    NSData *data = [base64Str dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersion ?: @"";
}

+ (NSString *)getTime {
    NSString*timeString = @"";
    @try {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        timeString = [NSString stringWithFormat:@"%0.0f", a*1000];
    } @catch (NSException *exception) {
        
    } @finally {
        return timeString;
    }
}

+ (NSString *)getMake {
    return @"apple";
}

+ (NSString *)getModel {
    NSString *model = @"";
    struct utsname systemInfo;
    uname(&systemInfo);
    model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return model;
}

+ (NSString *)getOsv {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getIdfa {
    // idfa是会变化的, 所以30天更新一次缓存
    NSString *idfa = [[NSUserDefaults standardUserDefaults] objectForKey:kIdfaDataKey];
    NSInteger expiredTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kIdfaExpiredKey] integerValue];
    
    if (!idfa.length || [[NSDate date] timeIntervalSince1970] > expiredTimestamp) { // 更新缓存
        /// 缓存过期时间戳
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970] + kExpireTimeForOneMonth;
        [[NSUserDefaults standardUserDefaults] setObject:@(timestamp) forKey:kIdfaExpiredKey];
        /// 缓存idfa
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if ([idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            idfa = @"";
        }
        [AdvDeviceManager saveEncodedString:idfa key:kIdfaDataKey];
        
        return idfa?:@"";
    }
    
    NSString *decrypt_idfa = advanceAesDecryptString(idfa, AdvanceSDKSecretKey);
    return decrypt_idfa;
}

+ (NSString *)getIdfv {
    // idfv是会变化的, 所以30天更新一次缓存
    NSString *idfv = [[NSUserDefaults standardUserDefaults] objectForKey:kIdfvDataKey];
    NSInteger expiredTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kIdfvExpiredKey] integerValue];
    
    if (!idfv.length || [[NSDate date] timeIntervalSince1970] > expiredTimestamp) { // 更新缓存
        /// 缓存过期时间戳
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970] + kExpireTimeForOneMonth;
        [[NSUserDefaults standardUserDefaults] setObject:@(timestamp) forKey:kIdfvExpiredKey];
        /// 缓存idfv
        idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [AdvDeviceManager saveEncodedString:idfv key:kIdfvDataKey];
        
        return idfv?:@"";
    }
    
    NSString *decrypt_idfv = advanceAesDecryptString(idfv, AdvanceSDKSecretKey);
    return decrypt_idfv;
}

+ (NSString *)getCarrier {
    // 每小时更新缓存
    NSString *carrier = [[NSUserDefaults standardUserDefaults] objectForKey:kCarrierDataKey];
    NSInteger expiredTimestamp = [[[NSUserDefaults standardUserDefaults] objectForKey:kCarrierExpiredKey] integerValue];
    
    if (!carrier.length || [[NSDate date] timeIntervalSince1970] > expiredTimestamp) { // 更新缓存
        NSString *mcc = @"";
        NSString *mnc = @"";
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc]init];
        if (@available(iOS 12, *)) {
            NSDictionary <NSString *, CTCarrier *> *carriers = nil;
            if (@available(iOS 12.1, *)) {
                carriers = [networkInfo serviceSubscriberCellularProviders];
            } else {
                carriers = [networkInfo valueForKey:@"serviceSubscriberCellularProvider"];
            }
            if (carriers) {
                for (CTCarrier *carrier in carriers.allValues) {
                    if ([carrier mobileCountryCode] && [carrier mobileNetworkCode]) {
                        mcc = [carrier mobileCountryCode];
                        mnc = [carrier mobileNetworkCode];
                        break;
                    }
                }
            }
            
        } else {
            CTCarrier *carrier = [networkInfo subscriberCellularProvider];
            mcc = [carrier mobileCountryCode];
            mnc = [carrier mobileNetworkCode];
        }
        
        carrier = [NSString stringWithFormat:@"%@%@",mcc,mnc];
        /// iOS16.4以后 CTCarrier被废弃返回“65535”，并且无替代方案。可尝试使用ipv6获取！
        if (![NSString adv_isEmptyString:carrier] && ![carrier isEqualToString:@"6553565535"]) {
            /// 缓存过期时间戳
            NSInteger timestamp = [[NSDate date] timeIntervalSince1970] + kExpireTimeForOneHour;
            [[NSUserDefaults standardUserDefaults] setObject:@(timestamp) forKey:kCarrierExpiredKey];
            /// 缓存Carrier
            [AdvDeviceManager saveEncodedString:carrier key:kCarrierDataKey];
            return carrier;
        }
        return @"";
    }
    
    NSString *decrypt_carrier = advanceAesDecryptString(carrier, AdvanceSDKSecretKey);
    return decrypt_carrier;
    
}

+ (NSNumber *)getNetwork {
    NSNumber *res = @(0);
    AdvReachability *reach = [AdvReachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case AdvNetworkStatusNotReachable: { // 没有网络
            res = @(0);
        } break;
        case AdvNetworkStatusReachableViaWiFi: { // WiFi
            res = @(1);
        } break;
        case AdvNetworkStatusReachableViaWWAN: { // 移动网络
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                //netconnType = @"GPRS";
                res = @2;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                // netconnType = @"2.75G EDGE";
                res = @2;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]) {
                //netconnType = @"3G";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]) {
                // netconnType = @"3.5G HSDPA";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]) {
                //  netconnType = @"3.5G HSUPA";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]) {
                //  netconnType = @"2G";
                res = @2;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]) {
                //  netconnType = @"3G";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]) {
                //  netconnType = @"3G";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]) {
                // netconnType = @"3G";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
                //  netconnType = @"HRPD";
                res = @3;
            } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]) {
                //  netconnType = @"4G";
                res = @4;
            } else if (@available(iOS 14.1, *)) {
                if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]){
                    res = @5;
                }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]){
                    res = @5;
                }
            }
        }
    }
    return res;
}

+ (NSNumber *)getDeviceType {
    NSString *model = [AdvDeviceManager getModel];
    if ([model containsString:@"iPhone"] || [model containsString:@"iPod"]) {
        return @1;
    } else if ([model containsString:@"iPad"]) {
        return @2;
    }
    return @0;
}

+ (NSString *)getUUID {
    NSString *uuidResult = @"";
    @try {
        NSString *uuidOrigin = [NSUUID UUID].UUIDString;
        NSString *uuidWithout = [uuidOrigin stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuidResult =[uuidWithout lowercaseString];
    } @catch (NSException *exception) {
        
    } @finally {
        return uuidResult;
    }
}

// 本地保存加密字符串
+ (void)saveEncodedString:(NSString *)info key:(NSString *)key {
    if ([NSString adv_isEmptyString:info] || [NSString adv_isEmptyString:key]) {
        return;
    }
    NSString *encryptText = advanceAesEncryptString(info, AdvanceSDKSecretKey);
    if ([NSString adv_isEmptyString:encryptText]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:encryptText forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
