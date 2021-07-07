//
//  KSAdSDKError.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/29.
//  Copyright © 2019 KuaiShou. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, KSAdErrorCode) {

    KSAdErrorCodeNoError = 1, // 成功

    KSAdErrorCodeNetworkError = 40001, // 网络错误
    KSAdErrorCodeDataParse = 40002, // data数据解析错误
    KSAdErrorCodeDataEmpty = 40003, // data empty
    KSAdErrorCodeCacheError = 40004, // 缓存出错

    KSAdErrorCodeNotVideoAd = 50001, // not a video ad
    KSAdErrorCodeParamWrong = 100001, // 参数有误
    KSAdErrorCodeServerError = 100002, // 服务器错误
    KSAdErrorCodeNoPermission = 100003, // 不允许的操作
    KSAdErrorCodeServerUnavailable = 100004, // 服务不可用
    KSAdErrorCodeNoMoreData = 100006, // 拉取内容视频时，没有更多了
    KSAdErrorCodeShareUrl = 100007, // 拉取分享接口，获取shareURL失败
    KSAdErrorCodeNoExistData = 130001, // 热点数据不存在

    KSAdErrorCodeAppIdUnregister = 310001, // appId 未注册
    KSAdErrorCodeAppIdInvalid = 310002, // appId 无效
    KSAdErrorCodeAppIdBanned = 310003, // appId 已封禁
    KSAdErrorCodePackageNameWrong = 310004, // packageName与注册的不一致；
    KSAdErrorCodeSystemOSWrong  = 310005, // 操作系统与注册的不一致

    KSAdErrorCodeSSPAccountInvalid = 320002, // appId 对应的账号无效
    KSAdErrorCodeSSPAccountBanned = 320003, // appId 对应的账号已封禁

    KSAdErrorCodePosIdUnregister = 330001, // posId 未注册
    KSAdErrorCodePosIdInvalid = 330002, // posId 无效
    KSAdErrorCodePosIdBanned = 330003, // posId 已封禁
    KSAdErrorCodePosIdUnmatched = 330004, // posId 与注册的 appId 不一致
    
    KSAdErrorCodeSecurityItemInvalid = 330010, //AppKey, wbIndex, .kss不合法或者与bundleid不匹配
};

typedef NS_ENUM(NSInteger, KSAdReportErrorCode) {
    KSAdReportErrorCodeSuccess,
    KSAdReportErrorCodeProtoToDataError = -1,
    KSAdReportErrorCodeServerError = -2,
    KSAdReportErrorCodeDataError = -3,
    KSAdReportErrorCodeNeedRemoveDBError = -4,
};

FOUNDATION_EXTERN NSErrorDomain KSADErrorDomain;



