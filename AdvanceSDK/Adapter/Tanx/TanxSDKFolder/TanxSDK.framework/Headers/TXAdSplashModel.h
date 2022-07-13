//
//  TXAdSplashModel.h
//  TanxSDK
//
//  Created by XY on 2021/12/27.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import <TanxSDK/TXAdCache.h>
#import <TanxSDK/TXAdEnum.h>


NS_ASSUME_NONNULL_BEGIN

@protocol TXAdSplashModel

@end

@interface TXAdSplashModel : JSONModel


@property(nonatomic, copy, readonly) NSString <Optional>*eCPM;  //返回广告的eCPM，单位：分

@property(nonatomic, copy, readonly) NSString *splashId;
@property(nonatomic, copy, readonly) NSString *creativeId;
@property(nonatomic, copy, readonly) NSString *templateId;
@property(nonatomic, copy, readonly) NSString *deeplinkUrl;
@property(nonatomic, copy, readonly) NSString *webUrl;
@property(nonatomic, copy, readonly) NSString *beginStamp;   //开始时间戳
@property(nonatomic, copy, readonly) NSString *endStamp;     //结束时间戳

@property(nonatomic, copy, readonly) NSString <Ignore>*reqId;
@property(nonatomic, copy, readonly) NSString <Ignore>*seatId;

@property(nonatomic, assign, readonly) NSInteger openType;

@property (nonatomic, copy, readonly) NSString <Optional>*assetUrl;
@property (nonatomic, copy, readonly) NSString <Optional>*width;
@property (nonatomic, copy, readonly) NSString <Optional>*height;
@property (nonatomic, copy, readonly) NSString <Optional>*assetMD5;
@property (nonatomic, copy, readonly) NSString <Optional>*title;
@property (nonatomic, copy, readonly) NSString <Optional>*advName;
@property (nonatomic, copy, readonly) NSString <Optional>*advLogo;

@property (nonatomic, copy, readonly) NSString <Optional>*sourceName;

@property (nonatomic, copy, readonly) NSArray<NSNumber *><Optional> * interactType;


- (instancetype)initWithAdDictionary:(NSDictionary *)dictionary
                               reqId:(NSString *)reqId
                              seatId:(NSString *)seatId;

///检查是否可用
- (BOOL)isValid;

- (TXAdFormatType)assetType;
- (void)setAssetType:(TXAdFormatType)assetType;

- (void)setFromeType:(NSInteger)fromeType;
- (NSInteger)fromeType;

///真实跳转url
- (NSString *)realJumpUrl;

- (TXAdCache *)getAdCache;

@end

NS_ASSUME_NONNULL_END
