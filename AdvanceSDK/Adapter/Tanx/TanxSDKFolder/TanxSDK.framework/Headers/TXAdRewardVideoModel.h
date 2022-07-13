//
//  TXAdRewardVideoModel.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/6/9.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdRewardVideoModel : JSONModel

@property(nonatomic, copy, readonly) NSString <Optional>*eCPM;
@property(nonatomic, copy, readonly) NSString *ID;
@property(nonatomic, copy, readonly) NSString *creativeId;
@property(nonatomic, copy, readonly) NSString *templateId;
@property(nonatomic, copy, readonly) NSString *deeplinkUrl;
@property(nonatomic, copy, readonly) NSString *webUrl;
@property(nonatomic, copy, readonly) NSString *beginStamp;
@property(nonatomic, copy, readonly) NSString *endStamp;
@property(nonatomic, copy, readonly) NSString <Ignore>*reqId;
@property(nonatomic, copy, readonly) NSString <Ignore>*seatId;

@property (nonatomic, copy, readonly) NSString <Optional>*imageUrl;
@property (nonatomic, copy, readonly) NSString <Optional>*imageWidth;
@property (nonatomic, copy, readonly) NSString <Optional>*imageHeight;
@property (nonatomic, copy, readonly) NSString <Optional>*imageMD5;

@property (nonatomic, copy, readonly) NSString <Optional>*title;
@property (nonatomic, copy, readonly) NSString <Optional>*advName;
@property (nonatomic, copy, readonly) NSString <Optional>*sourceName;
@property (nonatomic, copy, readonly) NSString <Optional>*advLogo;

@property(nonatomic, assign, readonly) NSInteger openType;

@property (nonatomic, copy, readonly) NSString <Optional>*actionText;
@property (nonatomic, copy, readonly) NSString <Optional>*desc;
@property (nonatomic, copy, readonly) NSString <Optional>*videoUrl;
@property (nonatomic, copy, readonly) NSString <Optional>*videoDuration;
@property (nonatomic, copy, readonly) NSString <Optional>*videoWidth;
@property (nonatomic, copy, readonly) NSString <Optional>*videoHeight;
@property (nonatomic, copy, readonly) NSString <Optional>*videoMD5;

@property (nonatomic, copy, readonly) NSString <Optional>*smImageUrl;
@property (nonatomic, copy, readonly) NSString <Optional>*smImageWidth;
@property (nonatomic, copy, readonly) NSString <Optional>*smImageHeight;
@property (nonatomic, copy, readonly) NSString <Optional>*smImageMD5;

@end

NS_ASSUME_NONNULL_END
