//
//  AdvanceDeviceInfoUtil.m
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvanceDeviceInfoUtil.h"
#import "AdvanceSdkConfig.h"
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

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation AdvanceDeviceInfoUtil
+ (NSMutableDictionary *)getDeviceInfoWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    NSMutableDictionary *deviceInfo = [[NSMutableDictionary alloc] init];
    @try {
        [deviceInfo setValue:AdvanceSdkVersion forKey:@"sdk_version"];
        [deviceInfo setValue:AdvanceSdkAPIVersion forKey:@"version"];
        [deviceInfo setValue:mediaId forKey:@"appid"];
        [deviceInfo setValue:adspotId forKey:@"adspotid"];
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getAppVersion] forKey:@"appver"];
        NSString *time = [AdvanceDeviceInfoUtil getTime];
        [deviceInfo setValue:time forKey:@"time"];
        //    [deviceInfo setValue:[AdvanceDeviceInfoUtil getUserAgent] forKey:@"ua"];
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getIPAddress:YES] forKey:@"ip"];
        //lat
        //lon
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getScreenWidth] forKey:@"sw"];
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getScreenHeight] forKey:@"sh"];
        //ppi
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getPPI] forKey:@"ppi"];
        //make
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getMake] forKey:@"make"];
        //model
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getModel] forKey:@"model"];
        //os
        [deviceInfo setValue:@1 forKey:@"os"];
        //osv
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getOsv] forKey:@"osv"];
        //idfa
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getIdfa] forKey:@"idfa"];
        //carrier
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getCarrier] forKey:@"carrier"];
        //network
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getNetwork] forKey:@"network"];
        //idfv
        [deviceInfo setValue:[AdvanceDeviceInfoUtil getIdfv] forKey:@"idfv"];
        return deviceInfo;
    } @catch (NSException *exception) {
        return deviceInfo;
    }

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

+ (NSString *)getMake {
    return @"apple";
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    __block NSString *address;
    @try {
        NSArray *searchArray = preferIPv4 ?
                @[IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6] :
                @[IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4];

        NSDictionary *addresses = [self getIPAddresses];
        //  BYLog(@"addresses: %@", addresses);

        [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            address = addresses[key];
            //筛选出IP地址格式
            if ([self isValidatIP:address]) *stop = YES;
        }];
    } @catch (NSException *exception) {
    } @finally {
        return address ? address : @"0.0.0.0";
    }

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

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    @try {
        // retrieve the current interfaces - returns 0 on success
        struct ifaddrs *interfaces;
        if (!getifaddrs(&interfaces)) {
            // Loop through linked list of interfaces
            struct ifaddrs *interface;
            for (interface = interfaces; interface; interface = interface->ifa_next) {
                if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                    continue; // deeply nested code harder to read
                }
                const struct sockaddr_in *addr = (const struct sockaddr_in *) interface->ifa_addr;
                char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
                if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                    NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                    NSString *type;
                    if (addr->sin_family == AF_INET) {
                        if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv4;
                        }
                    } else {
                        const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *) interface->ifa_addr;
                        if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv6;
                        }
                    }
                    if (type) {
                        NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                        addresses[key] = [NSString stringWithUTF8String:addrBuf];
                    }
                }
            }
            // Free memory
            freeifaddrs(interfaces);
        }
    } @catch (NSException *exception) {

    } @finally {
        return [addresses count] ? addresses : nil;
    }
}

+ (NSNumber *)getScreenHeight {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height * scale];

}

+ (NSNumber *)getScreenWidth {
    CGFloat scale = [UIScreen mainScreen].scale;
    return [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width * scale];
}

+ (NSNumber *)getPPI {
    NSNumber *ppi = @(0);
    @try {
        NSString *model = [AdvanceDeviceInfoUtil getModel];
        NSDictionary *modelPPiDict = [AdvanceDeviceInfoUtil getModelPPIDict];
        ppi = [modelPPiDict objectForKey:model];
        if (!ppi) {ppi = @401;}
    } @catch (NSException *exception) {

    } @finally {
        return ppi;
    }
}

+ (NSString *)getModel {
    NSString *model = @"";
    @try {
        struct utsname systemInfo;
        uname(&systemInfo);
        model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {

    } @finally {
        return model;
    }
}

+ (NSString *)getOsv {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSDictionary *)getModelPPIDict {   //https://en.wikipedia.org/wiki/List_of_iOS_devices
    return @{
            // 1st Gen
            @"iPhone1,1": @163,
            // 3G
            @"iPhone1,2": @163,
            // 3GS
            @"iPhone2,1": @163,
            //4
            @"iPhone3,1": @326,
            @"iPhone3,2": @326,
            @"iPhone3,3": @326,

            // 4S
            @"iPhone4,1": @326,

            // 5
            @"iPhone5,1": @326,
            @"iPhone5,2": @326,

            // 5c
            @"iPhone5,3": @326,
            @"iPhone5,4": @326,

            // 5s
            @"iPhone6,1": @326,
            @"iPhone6,2": @326,

            // 6 Plus
            @"iPhone7,1": @401,
            // 6
            @"iPhone7,2": @326,

            // 6s
            @"iPhone8,1": @326,

            // 6s Plus
            @"iPhone8,2": @401,

            // SE
            @"iPhone8,4": @326,

            // 7
            @"iPhone9,1": @326,
            @"iPhone9,3": @326,

            // 7 Plus
            @"iPhone9,2": @401,
            @"iPhone9,4": @401,

            //8
            @"iPhone10,1": @401,
            @"iPhone10,4": @401,

            //8 Plus
            @"iPhone10,2": @401,
            @"iPhone10,5": @401,

            //X
            @"iPhone10,3": @458,
            @"iPhone10,6": @458,
            //XS
            @"iPhone11,2": @458,
            //XS-MAX
            @"iPhone11,4": @458,
            @"iPhone11,6": @458,
            //XR
            @"iPhone11,8": @326,


            //iPod
            // 1st Gen
            @"iPod1,1": @163,

            // 2nd Gen
            @"iPod2,1": @163,

            // 3rd Gen
            @"iPod3,1": @163,

            // 4th Gen
            @"iPod4,1": @326,

            // 5th Gen
            @"iPod5,1": @326,

            // 6th Gen
            @"iPod7,1": @326,

            //iPad

            @"iPad1,1": @132,
            // 2
            @"iPad2,1": @132,
            @"iPad2,2": @132,
            @"iPad2,3": @132,
            @"iPad2,4": @132,

            // Mini
            @"iPad2,5": @163,
            @"iPad2,6": @163,
            @"iPad2,7": @163,

            // 3
            @"iPad3,1": @264,
            @"iPad3,2": @264,
            @"iPad3,3": @264,

            // 4
            @"iPad3,4": @264,
            @"iPad3,5": @264,
            @"iPad3,6": @264,

            // Air
            @"iPad4,1": @264,
            @"iPad4,2": @264,
            @"iPad4,3": @264,

            // Mini 2

            @"iPad4,4": @326,
            @"iPad4,5": @326,
            @"iPad4,6": @326,

            // Mini 3
            @"iPad4,7": @326,
            @"iPad4,8": @326,
            @"iPad4,9": @326,

            // Mini 4
            @"iPad5,1": @326,
            @"iPad5,2": @326,

            // Air 2
            @"iPad5,3": @264,
            @"iPad5,4": @264,

            // Pro 12.9-inch
            @"iPad6,7": @264,
            @"iPad6,8": @264,

            // Pro 9.7-inch
            @"iPad6,3": @264,
            @"iPad6,4": @264,

            // iPad 5th Gen, 2017

            @"iPad6,11": @264,
            @"iPad6,12": @264,

            // iPad 2018
            @"iPad7,5": @264,
            @"iPad7,6": @264,

    };

}

+ (NSString *)getIdfa {
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return idfa;
}

+ (NSString *)getCarrier {
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

+ (NSNumber *)getNetwork {
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


@end
