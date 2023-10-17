//
//  AdvDeviceInfoUtil.m
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvDeviceInfoUtil.h"
#import "AdvSdkConfig.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonCrypto.h>
#import "AdvanceAESCipher.h"
#import "AdvLog.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#define kTimeOutOneMonth 60 * 60 * 24 * 30 // 30天
//#define kTimeOutOneMonth 60 // 30天

#define kTimeOutOneHour 60 * 60 // 1小时
//#define kTimeOutOneHour 60  // 1小时

@interface AdvDeviceInfoUtil ()
/// 缓存的数据
@property (nonatomic, strong) NSMutableDictionary *cacheInfo;

@end

@implementation AdvDeviceInfoUtil

// MARK: 单例
static AdvDeviceInfoUtil *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

+ (id) allocWithZone:(struct _NSZone *)zone {
    return [AdvDeviceInfoUtil sharedInstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone {
    return [AdvDeviceInfoUtil sharedInstance] ;
}

- (NSMutableDictionary *)getDeviceInfoWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
    @try {
        if (self.cacheInfo) {
            deviceInfo = [self.cacheInfo mutableCopy];
            // 实时获取
            [deviceInfo setValue:mediaId forKey:@"appid"];
            [deviceInfo setValue:adspotId forKey:@"adspotid"];
            NSString *time = [AdvDeviceInfoUtil getTime];
            [deviceInfo setValue:time forKey:@"time"];

            deviceInfo = [self returnParametersWithDic:deviceInfo];
            deviceInfo = [self createDeviceEncinfoWithDic:deviceInfo];
            
            return deviceInfo;
            
        } else {
            self.cacheInfo = [[NSMutableDictionary alloc] init];
            
            // 实时获取
            [deviceInfo setValue:mediaId forKey:@"appid"];
            [deviceInfo setValue:adspotId forKey:@"adspotid"];
            NSString *time = [AdvDeviceInfoUtil getTime];
            [deviceInfo setValue:time forKey:@"time"];

            // 冷启动获取一次
            [deviceInfo setValue:AdvanceSdkVersion forKey:@"sdk_version"];
            [deviceInfo setValue:AdvanceSdkAPIVersion forKey:@"version"];
            [deviceInfo setValue:@1 forKey:@"os"];
            [deviceInfo setValue:@1 forKey:@"devicetype"];
            // 个性化广告推送开关
            [deviceInfo setValue:[AdvSdkConfig shareInstance].isAdTrack ? @"0" : @"1" forKey:@"donottrack"];
            
            // 加密
            [deviceInfo setValue:[AdvDeviceInfoUtil getOsv] forKey:@"osv"];
            [deviceInfo setValue:[AdvDeviceInfoUtil getAppVersion] forKey:@"appver"];

            // 只需要冷启动获取一次的字段
            self.cacheInfo = [deviceInfo mutableCopy]; ///<---------------
            deviceInfo = [self returnParametersWithDic:deviceInfo];
            deviceInfo = [self createDeviceEncinfoWithDic:deviceInfo];
            return deviceInfo;
        }

    } @catch (NSException *exception) {
        return deviceInfo;
    }

}

// 对获取好的参数进行加密处理
- (NSMutableDictionary *)createDeviceEncinfoWithDic:(NSMutableDictionary *)deviceInfo {
    NSMutableDictionary *encryptDic = [NSMutableDictionary dictionary];
    
    NSString *carrier = [deviceInfo objectForKey:@"carrier"];
    // 将正常的 值 放入需要加密的字典里然后再删除 deviceInfo中的该字段
    if (![self isEmptyString:carrier]) {
        [encryptDic setObject:carrier forKey:@"carrier"];
        [deviceInfo removeObjectForKey:@"carrier"];
    }
    
    NSNumber *network = [deviceInfo objectForKey:@"network"];
    [encryptDic setObject:network forKey:@"network"];
    [deviceInfo removeObjectForKey:@"network"];
    
    NSString *make = [deviceInfo objectForKey:@"make"];
    if (![self isEmptyString:make]) {
        [encryptDic setObject:make forKey:@"make"];
        [deviceInfo removeObjectForKey:@"make"];
    }
    
    NSString *model = [deviceInfo objectForKey:@"model"];
    if (![self isEmptyString:model]) {
        [encryptDic setObject:model forKey:@"model"];
        [deviceInfo removeObjectForKey:@"model"];
    }

    NSNumber *os = [deviceInfo objectForKey:@"os"];
    [encryptDic setObject:os forKey:@"os"];
    [deviceInfo removeObjectForKey:@"os"];

    NSString *osv = [deviceInfo objectForKey:@"osv"];
    if (![self isEmptyString:osv]) {
        [encryptDic setObject:osv forKey:@"osv"];
        [deviceInfo removeObjectForKey:@"osv"];
    }
    
    NSString *idfa = [deviceInfo objectForKey:@"idfa"];
    if (![self isEmptyString:idfa]) {
        [encryptDic setObject:idfa forKey:@"idfa"];
        [deviceInfo removeObjectForKey:@"idfa"];
    }

    NSString *idfv = [deviceInfo objectForKey:@"idfv"];
    if (![self isEmptyString:idfv]) {
        [encryptDic setObject:idfv forKey:@"idfv"];
        [deviceInfo removeObjectForKey:@"idfv"];
    }


    NSNumber *devicetype = [deviceInfo objectForKey:@"devicetype"];
    [encryptDic setObject:devicetype forKey:@"devicetype"];
    [deviceInfo removeObjectForKey:@"devicetype"];

    NSString *json = [self jsonStringCompactFormatForDictionary:encryptDic];
    ADVLog(@"设备信息 加密前: %@", json);
    NSString *jsonEncrypt = advanceAesEncryptString(json, AdvanceSDKSecretKey);
    jsonEncrypt = [self base64UrlEncoder:jsonEncrypt];
    ADVLog(@"设备信息 加密后: %@", jsonEncrypt);

    if ([self isEmptyString:jsonEncrypt]) {
        return deviceInfo;
    }
    
    [deviceInfo setObject:jsonEncrypt forKey:@"device_encinfo"];
        
    return deviceInfo;
}


// 获取参数(这些参数的加密时间缓存时间是不同的)
- (NSMutableDictionary *)returnParametersWithDic:(NSMutableDictionary *)deviceInfo {
    
    /// 永久存储加密
    /// make model
    NSMutableDictionary *dictForever = [self saveLocalForever];
    [deviceInfo addEntriesFromDictionary:dictForever];
    
    /// 一个月更新
    /// idfa idfv
    NSMutableDictionary *dictOneMonth = [self saveLocalForOneMonth];
    [deviceInfo addEntriesFromDictionary:dictOneMonth];

    /// 每小时更新
    /// carrier network
    NSMutableDictionary *dictOneHour = [self saveLocalForOneHour];
    [deviceInfo addEntriesFromDictionary:dictOneHour];


    NSString *reqid = [AdvDeviceInfoUtil getAuctionId];
    if (reqid) {
        [deviceInfo setValue:reqid forKey:@"reqid"];
    }
    return deviceInfo;
}


- (NSMutableDictionary *)saveLocalForever {

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //make
    [dic setValue:[self getMake] forKey:@"make"];
    //model
    [dic setValue:[self getModel] forKey:@"model"];


    return dic;
    
}

- (NSMutableDictionary *)saveLocalForOneMonth {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    NSString *idfa = [[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKIdfaKey];
    NSString *idfv = [[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKIdfvKey];
    
    NSInteger _timeout_stamp = [[[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKOneMonthKey] integerValue];

    // idfa idfv 时间戳任何一项都没问题 则直接返回dic
    if (![self isEmptyString:idfa] &&
        ![self isEmptyString:idfv] &&
        [[NSDate date] timeIntervalSince1970] < _timeout_stamp) {
        

        NSString *decryptIdfa = advanceAesDecryptString(idfa, AdvanceSDKSecretKey);
        NSString *decryptIdfv = advanceAesDecryptString(idfv, AdvanceSDKSecretKey);

        
        [dic setValue:decryptIdfa forKey:@"idfa"];
        [dic setValue:decryptIdfv forKey:@"idfv"];
    } else {
        // idfa idfv 时间戳任何一项有问题 都重新获取
        NSString *tempIdfa = [AdvDeviceInfoUtil getIdfa];
        NSString *tempIdfv = [AdvDeviceInfoUtil getIdfv];
        
        NSInteger __current_timeout_stamp = [[NSDate date] timeIntervalSince1970] + (kTimeOutOneMonth);
        NSNumber *__number = [NSNumber numberWithInteger:__current_timeout_stamp];

        [dic setValue:tempIdfa forKey:@"idfa"];
        [dic setValue:tempIdfv forKey:@"idfv"];

        
        [self saveInfo:tempIdfa key:AdvanceSDKIdfaKey];
        [self saveInfo:tempIdfv key:AdvanceSDKIdfvKey];
        [self saveNumber:__number key:AdvanceSDKOneMonthKey];
    }

    return dic;

}

- (NSMutableDictionary *)saveLocalForOneHour {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    /// carrier
//    [deviceInfo setValue:[AdvDeviceInfoUtil getCarrier] forKey:@"carrier"];
//    /// network
//    [deviceInfo setValue:[AdvDeviceInfoUtil getNetwork] forKey:@"network"];

    NSString *carrier = [[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKCarrierKey];
    NSNumber *network = [[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKNetworkKey];
    
    NSInteger _timeout_stamp = [[[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKHourKey] integerValue];

    
    // idfa idfv 时间戳任何一项都没问题 则直接返回dic
    if (![self isEmptyString:carrier] &&
        [[NSDate date] timeIntervalSince1970] < _timeout_stamp) {

        NSString *decryptText = advanceAesDecryptString(carrier, AdvanceSDKSecretKey);
                
        [dic setValue:decryptText forKey:@"carrier"];
        [dic setValue:network forKey:@"network"];
    } else {
        // idfa idfv 时间戳任何一项有问题 都重新获取
        NSString *tempCarrier = [self getCarrier];
        NSNumber *tempNetwork = [self getNetwork];
        
        NSInteger __current_timeout_stamp = [[NSDate date] timeIntervalSince1970] + (kTimeOutOneHour);
        NSNumber *__number = [NSNumber numberWithInteger:__current_timeout_stamp];

        [dic setValue:tempCarrier forKey:@"carrier"];
        [dic setValue:tempNetwork forKey:@"network"];

        
        [self saveInfo:tempCarrier key:AdvanceSDKCarrierKey];
        [self saveNumber:tempNetwork key:AdvanceSDKNetworkKey];
        [self saveNumber:__number key:AdvanceSDKHourKey];
    }

    return dic;

}

+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];

    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

+ (NSString *)getTime {
    NSString *timeString = @"";
    @try {
        NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970];
        timeString = [NSString stringWithFormat:@"%0.0f", a * 1000];
    } @catch (NSException *exception) {
    } @finally {
        return timeString;
    }
}

- (NSString *)getMake {
    return @"apple";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    BOOL passFlag = NO;
    @try {
        if (ipAddress.length == 0) {
            passFlag = NO;
        }
        NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
                             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
                             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
                             "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";

        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];

        if (regex && ipAddress) {
            NSTextCheckingResult *firstMatch = [regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];

            if (firstMatch) {
                //            NSRange resultRange = [firstMatch rangeAtIndex:0];
                //            NSString *result=[ipAddress substringWithRange:resultRange];
                //输出结果
                //           BYLog(@"%@",result);
                passFlag = YES;
            }
        }
        passFlag = NO;
    } @catch (NSException *exception) {
    } @finally {
        return passFlag;
    }
}

- (NSString *)getModel {
    
    NSString *model = [[NSUserDefaults standardUserDefaults] objectForKey:AdvanceSDKModelKey];

    if ([self isEmptyString:model]) {
        model = @"";
    } else {
        NSString *decryptText = advanceAesDecryptString(model, AdvanceSDKSecretKey);
        return decryptText;
    }
    
    @try {
        struct utsname systemInfo;
        uname(&systemInfo);
        model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        [self saveInfo:model key:AdvanceSDKModelKey];
    } @catch (NSException *exception) {

    } @finally {
        return model;
    }
}

+ (NSString *)getOsv {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getIdfa {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    return idfa;
}

- (NSString *)getCarrier {
    NSString *result = @"";
    @try {
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mcc = [carrier mobileCountryCode];
        NSString *mnc = [carrier mobileNetworkCode];
        if (!mcc) {
            return @"";
        }
        result = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    } @catch (NSException *exception) {

    } @finally {
        return result;
    }
}

- (NSNumber *)getNetwork {
    NSNumber *res = @(0);
    @try {
        NSCountedSet *cset = [[NSCountedSet alloc] init];
        struct ifaddrs *interfaces;
        if (!getifaddrs(&interfaces)) {
            for (struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
                if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                    [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
                }
            }
        }
        if ([cset countForObject:@"awdl0"] > 1) {
            res = @1;
        }
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
        } else {//TD-SCDMA WCDMA CDMA2000
            res = @3;
        }
    } @catch (NSException *exception) {

    } @finally {
        return res;
    }
}

+ (NSString *)getIdfv {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

+ (NSString *)getAuctionId {
    @try {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        return [[uuid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
    } @catch (NSException *exception) {
        return @"";
    }
}

- (BOOL)isEmptyString:(NSString *)string{
       if(string == nil) {
            return YES;
        }
        if (string == NULL) {
            return YES;
        }
        if ([string isKindOfClass:[NSNull class]]) {
            return YES;
        }
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
            return YES;
        }
    return NO;
}

- (void)saveInfo:(NSString *)info key:(NSString *)key {
    if ([self isEmptyString:info] || [self isEmptyString:key]) {
        return;
    }
    
    NSString *encryptText = advanceAesEncryptString(info, AdvanceSDKSecretKey);
    
    if ([self isEmptyString:encryptText]) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:encryptText forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)saveNumber:(NSNumber *)time key:(NSString *)key {
    if ([self isEmptyString:key]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

// 字典转json
- (NSString *)jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}

// base64 url 编码
- (NSString *)base64UrlEncoder:(NSString *)str {
//    NSData *data = [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
//    NSMutableString *base64Str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    str = (NSMutableString * )[str stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return str;
}



@end
