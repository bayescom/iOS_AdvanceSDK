//
//  TXAdEnum.h
//  TanxSDK-iOS
//
//  Created by guqiu on 2021/12/15.
//

#ifndef TXAdEnum_h
#define TXAdEnum_h

#define TXADSDK_ERROR_DOMAIN @"txadsdk.error.domain"


typedef NS_ENUM(NSInteger, TXAdSDKLogLevel) {
    TXAdSDKLogLevelNone,
    TXAdSDKLogLevelError,
    TXAdSDKLogLevelWarning,
    TXAdSDKLogLevelInfo,
    TXAdSDKLogLevelDebug,
    TXAdSDKLogLevelVerbose,
};



///广告素材类型
typedef NS_ENUM(NSInteger, TXAdFormatType) {
    TXAdFormatUnknown              = 0,
    TXAdFormatGeneralVideo         = 1,
    TXAdFormatHTML,
    TXAdFormatImage,
};

///广告位
#warning TODO 值未对齐
typedef NS_ENUM(NSInteger, TXAdType) {
    TXAdTypePre            = 7,
    TXAdTypeMiddle         = 8,
    TXAdTypePost           = 9,
    TXAdTypePause          = 10,
    TXAdTypeSplash         = 12,
    TXAdTypeScene          = 23,
    TXAdTypeCarousel       = 25,
    TXAdTypeStreaming      = 27,
    TXAdTypeSoft           = 932,
    TXAdTypeVB             = 2002,
    TXAdTypePop            = 2008,
    TXAdTypePlayerBanner   = 1433218285
};



typedef NS_ENUM(NSInteger, TXAdSdkErrorCode) {
    TXAdErrorSplashError = 7000,
    TXAdErrorSplashDataInvalid = 8000,
    TXAdErrorSplashEmpty,
    TXAdErrorSplashExpired,
    TXAdErrorSplashAssetNotFound,
    TXAdErrorSplashUnsupportFormat,
    TXAdErrorSplashUnsupportSerialized,
    TXAdErrorSplashSerializedAssetNotFound,
    TXAdErrorSplashNoMatchFound,
    TXAdErrorSplashAlreadyStart,
    TXAdErrorCacheMd5Mismatch = 9000,
    TXAdErrorCacheLengthMismatch,
    TXAdErrorCacheFileExist,
    TXAdErrorSplashSizeTooSmall,    //尺寸太小
    TXAdErrorSplashTimeOut,          //开屏超时
    TXAdErrorSplashPidInvalid,
};



#endif /* TXAdEnum_h */
