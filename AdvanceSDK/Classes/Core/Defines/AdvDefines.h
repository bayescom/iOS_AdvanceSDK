
typedef NS_ENUM(NSUInteger, AdvSupplierReportTKEventType) {
    /// 渠道SDK 启动成功
    AdvSupplierReportTKEventLoaded = 0,
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
    AdvErrorCode_SDKInitException = 7103,
    /// 策略请求超时
    AdvErrorCode_Timeout = 71000,
    /// 网络层异常（除超时外）
    AdvErrorCode_NetworkError = 71001,
    /// 无网络
    AdvErrorCode_NoNetwork = 71002,
    /// 策略返回数据类型错误
    AdvErrorCode_ResponseTypeError = 7210,
    /// 策略中未配置渠道，请联系相关运营人员配置
    AdvErrorCode_NoneSupplier = 7217,
    /// 策略返回数据模型解析失败
    AdvErrorCode_ParseModelError = 7218,
    /// 策略接口服务器返回Code值非200
    AdvErrorCode_Not200 = 7220,
    /// 渠道广告加载超时
    AdvErrorCode_SupplierTimeout = 7321,
    /// 广告展示前广告已失效过期
    AdvErrorCode_InvalidExpired = 7322,
    /// 所有平台都未返回广告（失败或超时）
    AdvErrorCode_AllLoadAdFailed = 7323,
    /// 所有渠道SDK都未安装
    AdvErrorCode_SupplierUninstalled = 7401,
    /// 渠道SDK初始化失败
//    AdvErrorCode_SupplierInitFailed = 7402,
    
};
