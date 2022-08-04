//
//  TXAdSeat.h
//  TanxCoreSDK
//
//  Created by XY on 2021/12/30.
//  Copyright © 2021 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>


NS_ASSUME_NONNULL_BEGIN


@protocol TXAdSeat
@end

@interface TXAdSeat : JSONModel

@property (nonatomic, copy, readonly)         NSString *seatId;
@property (nonatomic, copy, readonly)         NSArray *ads;


@end

NS_ASSUME_NONNULL_END
