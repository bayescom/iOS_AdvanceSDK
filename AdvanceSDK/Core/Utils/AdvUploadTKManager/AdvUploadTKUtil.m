//
//  AdvUploadTKUtil.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/19.
//

#import "AdvUploadTKUtil.h"
#import "AdvUploadTKManager.h"
#import "AdvSupplierModel.h"
#import "AdvLog.h"

#define MAXOPERATIONCOUNT 10
#define TIMEOUT 5

@interface AdvUploadTKUtil ()

@end

@implementation AdvUploadTKUtil

- (void)setServerTime:(NSTimeInterval)serverTime {
    _serverTime = serverTime;
}

- (void)setReqid:(NSString *)reqid {
    _reqid = reqid;
}

- (void)reportWithUploadArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error {
    NSMutableArray *temp = [NSMutableArray array];
    for (id obj in uploadArr) {
        @try {
            NSString *urlString = obj;
            urlString = [self paramValueOfUrl:obj withParam:@"&reqid"];
            NSTimeInterval timeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"__TIME__" withString:[NSString stringWithFormat:@"%0.0f", timeStamp]];
            
            
            
            ADV_LEVEL_INFO_LOG(@"TK上报===>> %@", urlString);
            [temp addObject:urlString];
            
        } @catch (NSException *exception) {
        } @finally {
        }
    }
    
    [AdvUploadTKManager defaultManager].maxConcurrentOperationCount = MAXOPERATIONCOUNT;
    [AdvUploadTKManager defaultManager].timeoutInterval = TIMEOUT;
    [[AdvUploadTKManager defaultManager] uploadTKWithUrls:[temp copy]];
}

- (NSString *)paramValueOfUrl:(NSString *)url withParam:(NSString *)param {
    @try {
        if ([url containsString:param]) {
            NSRange range =  [url rangeOfString:param];
            
            // 定义要删除按的reqid
            NSString *reqidValue = [NSString stringWithFormat:@"reqid=%@", self.reqid];
            
            // 找到原url当中 reqid=balabalabala
            NSRange rangeReq = NSMakeRange(range.location + 1, 38);
            NSString * parametersString = [url substringWithRange:rangeReq];
    //        [url  substringFromIndex:range.location];
            if ([parametersString containsString:@"&"]) { // reqid=balabalabala 包含了& 说明截取不准确返回的url有问题 则不进行替换工作
                return url;
            }
            url = [url stringByReplacingOccurrencesOfString:parametersString withString:reqidValue];
        }
    } @catch (NSException *exception) {
        return url;
    }
    return url;
}

#pragma succeedtk 的参数拼接
- (NSMutableArray *)succeedtkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *succeedtk = [self joinPriceUrlWithObj:obj price:price];
        [temp addObject:succeedtk];
    }
    return temp;
}


#pragma loadedtk 的参数拼接
- (NSMutableArray *)loadedtkUrlWithArr:(NSArray<NSString *> *)uploadArr {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *loadedtk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoLoaded];
        [temp addObject:loadedtk];
    }
    return temp;
}

#pragma imptk 的参数拼接
- (NSMutableArray *)imptkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *loadedtk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoImped];
        loadedtk = [self joinPriceUrlWithObj:loadedtk price:price];
        [temp addObject:loadedtk];
    }
    return temp;
}

#pragma failedtk 的参数拼接
- (NSMutableArray *)failedtkUrlWithArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *failed = [self joinFailedUrlWithObj:obj error:error];
        [temp addObject:failed];
    }
    return temp;
}
 
#pragma 错误码参数拼接
- (NSString *)joinFailedUrlWithObj:(NSString *)urlString error:(NSError *)error {
    ADV_LEVEL_INFO_LOG(@"上报错误: %@  %@", error.domain, error);
    if (error) {

        if ([error.domain isEqualToString:@"KSADErrorDomain"]) { // 快手SDK
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_ks_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"BDAdErrorDomain"]) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_bd_%ld&track_time",(long)error.code]];

        } else if ([error.domain isEqualToString:@"com.pangle.buadsdk"] || [error.domain isEqualToString:@"com.buadsdk"]) { // 新版穿山甲sdk报错
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_csj_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"com.bytedance.buadsdk"]) {// 穿山甲sdk报错
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_csj_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"GDTAdErrorDomain"]) {// 广点通
            NSString *url = nil;
            if (error.code == 6000 && error.localizedDescription != nil) {
                
                @try {
                    //过滤字符串前后的空格
                    NSString *errorDescription = [error.localizedDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    //过滤字符串中间的空格
                    errorDescription = [errorDescription stringByReplacingOccurrencesOfString:@" " withString:@""];
                    ////匹配error.localizedDescription当中的"详细码:"得到的下标
                    NSRange range = [errorDescription rangeOfString:@"详细码:"];
                    // 截取"详细码:"后6位字符串
                    NSString *subCodeString = [errorDescription substringWithRange:NSMakeRange(range.location + range.length, 6)];
                    url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld_%@&track_time",(long)error.code, subCodeString]];
                } @catch (NSException *exception) {
                    url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld&track_time",(long)error.code]];
                }
            } else {
                url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld&track_time",(long)error.code]];
            }
            return url;
        } else {// 倍业
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_mer_%ld&track_time",(long)error.code]];
        }
    }
    return urlString;
}


/// 拼接时间戳
/// @param urlString url
/// @param repoType AdvanceSdkSupplierRepoType
- (NSString *)joinTimeUrlWithObj:(NSString *)urlString type:(AdvanceSdkSupplierRepoType)repoType {
    NSTimeInterval serverTime = [[NSDate date] timeIntervalSince1970]*1000 - _serverTime;
    if (serverTime > 0) {
        if (repoType == AdvanceSdkSupplierRepoLoaded) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=l_%.0f&track_time",serverTime]];
        } else if (repoType == AdvanceSdkSupplierRepoImped) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=tt_%.0f&track_time",serverTime]];
        }
    }
    return urlString;
}

// 拼接价格
- (NSString *)joinPriceUrlWithObj:(NSString *)urlString price:(NSInteger)price {
    if (price > 0) {
        return  [NSString stringWithFormat:@"%@&bidResult=%ld", urlString, (long)price];
    } else {
        return urlString;
    }
}


@end
