//
//  AdvTanxRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <TanxSDK/TanxSDK.h>

@interface AdvTanxRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithAdModel:(TXAdModel *)adModel;

@end
