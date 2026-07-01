//
//  AdvGZipRequestSerializer.h
//  MercurySDK
//
//  Created by guangyao on 2025/11/20.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvAFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvGZipRequestSerializer : AdvAFJSONRequestSerializer

@property (nonatomic, assign) NSUInteger compressionThreshold; // 压缩阈值（字节数）

+ (instancetype)serializer;

@end

NS_ASSUME_NONNULL_END
