//
//  TXAdFeedModel.h
//  TanxSDK
//
//  Created by guqiu on 2021/12/28.
//  Copyright © 2021 tanx.com. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import <TanxSDK/TXAdMonitor.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdFeedModel : JSONModel

@property(nonatomic, copy, readwrite) NSString <Ignore>*reqId;

@property(nonatomic, copy, readonly) NSString <Optional>*eCPM;      //返回广告的eCPM，单位：分
@property(nonatomic, copy, readonly) NSString <Optional>*winnoticeUrl;      //竞价成功的上报地址

@property(nonatomic, copy, readonly) NSString <Optional>*creativeId;
@property(nonatomic, copy, readonly) NSString <Optional>*templateId;

@property(nonatomic, copy, readonly) NSString <Optional>*startStamp;
@property(nonatomic, copy, readonly) NSString <Optional>*endStamp;
@property(nonatomic, copy, readonly) NSString <Ignore>*seatId;
@property(nonatomic, copy, readonly) NSString <Optional>*rankId;

@property(nonatomic, copy, readonly) NSArray <NSString *><Optional>*impression_tracking_url;
@property(nonatomic, copy, readonly) NSArray <NSString *><Optional>*click_tracking_url;
@property(nonatomic, copy, readonly) NSArray <TXAdMonitor *><Optional>*event_track;

@property (nonatomic, copy, readonly) NSString <Optional>*assetUrl;
@property (nonatomic, assign, readonly) NSInteger width;
@property (nonatomic, assign, readonly) NSInteger height;
@property (nonatomic, assign, readonly) NSInteger position;
@property (nonatomic, copy, readonly) NSString <Optional>*title;
@property (nonatomic, copy, readonly) NSString <Optional>*adName;
@property (nonatomic, copy, readonly) NSString <Optional>*adWords;
@property (nonatomic, copy, readonly) NSString <Optional>*adImage;
@property (nonatomic, copy, readonly) NSString <Optional>*sourceName;

@property (nonatomic, assign, readonly) NSInteger openType;
@property (nonatomic, copy, readonly) NSString <Optional>*dpUrl;
@property (nonatomic, copy, readonly) NSString <Optional>*destUrl;

@end

NS_ASSUME_NONNULL_END
