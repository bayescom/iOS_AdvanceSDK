//
//  TXAdDetailWebView.h
//  TanxSDK
//
//  Created by XY on 2022/1/6.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TanxSDK/TXAdSplashModel.h>


NS_ASSUME_NONNULL_BEGIN



@protocol TXAdDetailWebViewDelegate <NSObject>

//- (void)onWebViewShouldLoad;


- (void)onWebViewLoaded:(NSTimeInterval)time;

- (void)onWebViewLoadError:(NSError*)error;

- (void)onWebViewClose;

@end


@interface TXAdDetailWebView : UIView

-(instancetype)initWithFrame:(CGRect)frame withDelegate:(id<TXAdDetailWebViewDelegate>)delegate
                    withModel:(TXAdSplashModel*)model;

@property(nonatomic, strong)UIColor *navgationBackgroundColor;
@property(nonatomic, strong)UIColor *navgationTextColor;


@end

NS_ASSUME_NONNULL_END
