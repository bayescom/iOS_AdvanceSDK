//
//  AdvUploadTKUtil.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/19.
//

#import "AdvUploadTKUtil.h"
#import "AdvUploadTKManager.h"
#import "AdvPolicyModel.h"
#import "AdvLog.h"

#define MAXOPERATIONCOUNT 10
#define TIMEOUT 5

@interface AdvUploadTKUtil ()

@end

@implementation AdvUploadTKUtil

- (void)reportWithUploadUrls:(NSArray<NSString *> *)uploadUrls {
    NSMutableArray *temp = [NSMutableArray array];
    for (id obj in uploadUrls) {
        NSString *urlString = obj;
        NSTimeInterval timeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        urlString = [urlString stringByReplacingOccurrencesOfString:@"__TIME__" withString:[NSString stringWithFormat:@"%0.0f", timeStamp]];
        [temp addObject:urlString];
    }
    
    [AdvUploadTKManager defaultManager].maxConcurrentOperationCount = MAXOPERATIONCOUNT;
    [AdvUploadTKManager defaultManager].timeoutInterval = TIMEOUT;
    [[AdvUploadTKManager defaultManager] uploadTKWithUrls:[temp copy]];
}

#pragma mark: - loadedtk 参数拼接
- (NSMutableArray *)loadedtkUrlWithArr:(NSArray<NSString *> *)uploadArr {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr) {
        NSString *loadedtk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoLoaded];
        [temp addObject:loadedtk];
    }
    return temp;
}

#pragma mark: - succeedtk 参数拼接
- (NSMutableArray *)succeedtkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *succeedtk = [self joinPriceUrlWithObj:obj price:price];
        [temp addObject:succeedtk];
    }
    return temp;
}

#pragma mark: failedtk 参数拼接
- (NSMutableArray *)failedtkUrlWithArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *failedtk = [self joinFailedUrlWithObj:obj error:error];
        [temp addObject:failedtk];
    }
    return temp;
}

#pragma mark: - imptk 参数拼接
- (NSMutableArray *)imptkUrlWithArr:(NSArray<NSString *> *)uploadArr price:(NSInteger)price {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *imptk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoImped];
        imptk = [self joinPriceUrlWithObj:imptk price:price];
        [temp addObject:imptk];
    }
    return temp;
}
 
/// 拼接时间戳
/// @param urlString url
/// @param repoType AdvanceSdkSupplierRepoType
- (NSString *)joinTimeUrlWithObj:(NSString *)urlString type:(AdvanceSdkSupplierRepoType)repoType {
    NSTimeInterval serverTime = [[NSDate date] timeIntervalSince1970] * 1000 - _requestTime;
    if (serverTime > 0) {
        if (repoType == AdvanceSdkSupplierRepoLoaded) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=l_%.0f&track_time",serverTime]];
        } else if (repoType == AdvanceSdkSupplierRepoImped) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=tt_%.0f&track_time",serverTime]];
        }
    }
    return urlString;
}

/// 拼接价格
- (NSString *)joinPriceUrlWithObj:(NSString *)urlString price:(NSInteger)price {
    if (price > 0) {
        return  [NSString stringWithFormat:@"%@&bidResult=%ld", urlString, (long)price];
    } else {
        return urlString;
    }
}

/// 拼接错误码
- (NSString *)joinFailedUrlWithObj:(NSString *)urlString error:(NSError *)error {
    ADVLog(@"上报错误: %@  %@", error.domain, error);
    if (error) {
        if ([error.domain.lowercaseString containsString:@"ks"]) { // 快手SDK
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_ks_%ld&track_time",(long)error.code]];
        } else if ([error.domain.lowercaseString containsString:@"bd"]) { // 百度SDK
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_bd_%ld&track_time",(long)error.code]];
        } else if ([error.domain.lowercaseString containsString:@"bu"]) { // 穿山甲SDK
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_csj_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"com.bytedance.GroMore"]) { // GM
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gm_%ld&track_time",(long)error.code]];
        } else if ([error.domain.lowercaseString containsString:@"mercury"])  {// 倍业SDK
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_mer_%ld&track_time",(long)error.code]];
        } else if ([error.domain.lowercaseString containsString:@"gdt"]) {// 广点通
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
        }
    }
    return urlString;
}

@end
