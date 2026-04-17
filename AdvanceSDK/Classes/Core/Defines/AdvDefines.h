
typedef NS_ENUM(NSUInteger, AdvSupplierReportTKEventType) {
    /// 渠道SDK 启动
    AdvSupplierReportTKEventLoaded = 0,
    /// 渠道SDK 初始化成功
    AdvSupplierReportTKEventLoadEnd,
    /// 渠道SDK广告 获取成功
    AdvSupplierReportTKEventSucceed,
    /// 渠道SDK广告 获取/渲染/超时 失败
    AdvSupplierReportTKEventFailed,
    /// 渠道SDK广告 曝光成功
    AdvSupplierReportTKEventExposed,
    /// 渠道SDK广告 产生点击
    AdvSupplierReportTKEventClicked,
    /// 结束bidding 某个渠道广告竞胜
    AdvSupplierReportTKEventBidWin,
};

// 渠道加载广告状态
typedef NS_ENUM(NSUInteger, AdvSupplierLoadAdState) {
    /// 准备就绪
    AdvSupplierLoadAdReady = 0,
    /// 渠道请求广告素材成功
    AdvSupplierLoadAdSuccess,
    /// 渠道请求广告素材失败
    AdvSupplierLoadAdFailed,
    /// 渠道请求广告素材超时
    AdvSupplierLoadAdTimeout,
};

// SDK错误码
typedef NS_ENUM(NSUInteger, AdvErrorCode) {
    /// SDK初始化失败
    AdvErrorCode_SDKInitException = 9103,
    /// 策略请求超时
    AdvErrorCode_Timeout = 91000,
    /// 网络层异常（除超时外）
    AdvErrorCode_NetworkError = 91001,
    /// 无网络
    AdvErrorCode_NoNetwork = 91002,
    /// 策略返回数据类型错误
    AdvErrorCode_ResponseTypeError = 9210,
    /// 策略中未配置渠道，请联系相关运营人员配置
    AdvErrorCode_NoneSupplier = 9217,
    /// 策略返回数据模型解析失败
    AdvErrorCode_ParseModelError = 9218,
    /// 策略接口服务器返回Code值非200
    AdvErrorCode_Not200 = 9220,
    /// 渠道广告加载超时
    AdvErrorCode_SupplierTimeout = 9321,
    /// 广告展示前广告已失效过期
    AdvErrorCode_InvalidExpired = 9322,
    /// 所有平台都未返回广告（失败或超时）
    AdvErrorCode_AllLoadAdFailed = 9323,
    /// 所有渠道SDK都未安装
    AdvErrorCode_SupplierUninstalled = 9401,
    /// 渠道SDK初始化失败
//    AdvErrorCode_SupplierInitFailed = 9402,
    
};
