//
//  XAdInfo.h
//  TXAdSDK
//
//  Created by oliver on 2020/4/14.
//  Copyright © 2020 youdo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <TanxSDK/TXAdSeat.h>

#ifndef _XAD_RESPONSE_
#define _XAD_RESPONSE_

@protocol TXAdResponse
@end

@interface TXAdResponse : JSONModel

@property (nonatomic, assign, readonly)       NSInteger status;
@property (nonatomic, copy, readonly)         NSArray<NSDictionary *> <Optional> *seatDicts;
@property (nonatomic, copy, readwrite)         NSString<Optional> *reqId;

- (NSArray<TXAdSeat *> *)seats;

- (instancetype)initWithData:(NSData *)data withExtra:(NSDictionary*)extra;

- (instancetype)initWithDictionary:(NSDictionary *)dict withExtra:(NSDictionary*)extra;


@end

#endif
