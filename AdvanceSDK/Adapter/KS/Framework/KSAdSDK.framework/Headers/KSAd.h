//
//  KSAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/30.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSAdInteractionType) {
    KSAdInteractionType_Unknown,        //unknown type
    KSAdInteractionType_App,            //open downlaod page in app
    KSAdInteractionType_Web,            //open webpage in app
    KSAdInteractionType_DeepLink,       //open deeplink
    KSAdInteractionType_AppStore,       //open appstore
};

typedef NS_ENUM(NSInteger, KSAdMaterialType) {
    KSAdMaterialTypeUnkown      =       0,      // unknown
    KSAdMaterialTypeVideo       =       1,      // video
    KSAdMaterialTypeSingle      =       2,      // single image
    KSAdMaterialTypeAtlas       =       3,      // multiple image
};

NS_ASSUME_NONNULL_BEGIN

@interface KSAd : NSObject

/// ad interaction type, avaliable after ad load
@property (nonatomic, assign, readonly) KSAdInteractionType interactionType;
/// ad material type, avaliable after ad load
@property (nonatomic, assign, readonly) KSAdMaterialType materialType;

// 单位:分，只有视频资源下载成功后，这个才可能有值
@property (nonatomic, readonly) NSInteger ecpm;
/// 媒体二次议价, 单位分
- (void)setBidEcpm:(NSInteger)ecpm;

@end

NS_ASSUME_NONNULL_END
