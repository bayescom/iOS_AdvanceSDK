//
//  AdvUploadTKManager.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

/*
 该组件负责倍业聚合SDK各广告位生命周期节点的上报, 主要职责及功能设置包括以下几点
 1.支持设置最大并发数
 2.支持每个url设置最大超时时间
 3.支持当队列中进行的任务为0时, 回调相关信息(可选)
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, AdvUploadTkCompleteCode) {
    AdvUploadTkCompleteCode_Succees = 100,// 全部成功没有失败
    AdvUploadTkCompleteCode_Completed,// 没有全部成功, 仅完成了上传流程
};

/// 本组上传完成
/// @param sign 自定义标志, 用来标志本组url
/// @param code 状态码
typedef void(^AdvUploadTkComplete)(NSString *sign, AdvUploadTkCompleteCode code);

/// 失败的回调
/// @param url 上传失败的url
/// @param code 状态码
typedef void(^AdvUploadTkFail)(NSString *url, NSInteger code);
/// 注意:
/// 1.上传完成, 不意味着所有的url都上传成功,  只是所有的url都有了上传结果(可能成功,也可能失败)
/// 2.某个url上传失败时, 会通过AdvUploadTkFail 回调出来



@interface AdvUploadTKManager : NSObject
+ (AdvUploadTKManager *)defaultManager;

// 最大并发数 请在上传开始之前设置 默认为5
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

// 每个url的超时时间 默认为5 请在上传开始之前设置
@property (nonatomic, assign) NSInteger timeoutInterval;


/// 上传方法
/// @param urls TKs
- (void)uploadTKWithUrls:(NSArray *)urls;


/// 带回调的上传方法
/// @param urls TKs
/// @param sign 本组上传的标志
/// @param completeBlock 每个TK成功后都会回调
/// @param failBlock 每个TK失败后都会回调
/// 这两个回调都会触发多次
- (void)uploadTKWithUrls:(NSArray *)urls
                    sign:(NSString *)sign
                complete:(AdvUploadTkComplete)completeBlock
                    fail:(AdvUploadTkFail)failBlock;
@end
