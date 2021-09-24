//
//  AdvTrackEventParameters.m
//  AdvanceSDK
//
//  Created by MS on 2021/9/9.
//

#import "AdvTrackEventParameters.h"
#import "AdvDeviceInfoUtil.h"
@interface AdvTrackEventParameters ()
@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, copy) NSString *mediaId;

@end

@implementation AdvTrackEventParameters
- (instancetype)initUtilWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    self = [super init];
    if (self) {
        self.adspotId = adspotId;
        self.mediaId = mediaId;
    }
    return self;
}

- (void)advTrackEventParametersActionWithCase:(AdvTrackEventCase)eventCase {
    switch (eventCase) {
        case AdvTrackEventCase_getInfo:
            
//            NSDictionary *dict =
            
            [self getInfo];
            break;
        case AdvTrackEventCase_getAction:

            [self getData];
            break;

        default:
            break;
    }
}

- (void)getInfo {
    NSMutableDictionary *dict = [AdvDeviceInfoUtil getSDKTrackEventDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    [dict setObject:@"测试获取信息" forKey:@"msg"];
    [self getInfoAction:dict];
}

- (void)getInfoAction:(NSDictionary *)dict {
    
}


- (void)getData {
    NSMutableDictionary *dict = [AdvDeviceInfoUtil getSDKTrackEventDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    [dict setObject:@"测试数据拉取" forKey:@"msg"];
    [self getDataAction:dict];
}


- (void)getDataAction:(NSString *)str {
    
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
    
}
@end
