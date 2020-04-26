//
//  SdkSupplier.h
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SdkSupplier : NSObject
@property(strong, nonatomic) NSString *id;
@property(strong, nonatomic) NSString *name;
@property(assign, nonatomic) int priority;
@property(assign, nonatomic) int timeout;
@property(strong, nonatomic) NSString *mediaid;
@property(strong, nonatomic) NSString *adspotid;
@property(strong, nonatomic, nullable) NSString *mediakey;
@property(strong, nonatomic) NSString *sdkTag;
@property(assign, nonatomic) int adCount;
@property(strong, nonatomic, nullable) NSArray<NSString *> *imptk;
@property(strong, nonatomic, nullable) NSArray<NSString *> *clicktk;
@property(strong, nonatomic, nullable) NSArray<NSString *> *succeedtk;
@property(strong, nonatomic, nullable) NSArray<NSString *> *failedtk;
@property(strong, nonatomic, nullable) NSArray<NSString *> *loadedtk;
@property(strong, nonatomic, nullable) NSArray<NSString *> *ext;

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid mediaKey:(nullable NSString *)mediakey sdkId:(NSString *)sdkId;

+ (void)sortByPriority:(nullable NSMutableArray<SdkSupplier *> *)sdkList;

@end

NS_ASSUME_NONNULL_END
