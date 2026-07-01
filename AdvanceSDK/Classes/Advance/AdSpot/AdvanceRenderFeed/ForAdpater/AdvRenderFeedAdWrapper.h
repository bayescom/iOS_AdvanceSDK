//
//  AdvRenderFeedAdWrapper.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdViewCreator.h"
#import "AdvRenderFeedAdDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvRenderFeedAdWrapper : NSObject

// 广告物料，包含有最全的广告数据
@property (nonatomic, strong) id<AdvRenderFeedAdDataSource> dataSource;

// 广告视图创建对象，对常用广告展示元素进行创建（存在意义：对部分adn创建特定视图的支持）
@property (nonatomic, strong) id<AdvRenderFeedAdViewCreator> viewCreator;

// 广告视图对象（存在意义：对部分adn创建特定视图的支持）
@property (nonatomic, strong) UIView *view;

@end

NS_ASSUME_NONNULL_END
