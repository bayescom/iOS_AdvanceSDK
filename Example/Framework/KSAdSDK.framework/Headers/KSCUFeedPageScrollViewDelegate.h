//
//  KSCUFeedPageScrollViewDelegate.h
//  KSAdSDK
//
//  Created by jie cai on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KSCUFeedPageScrollViewDelegate <UIScrollViewDelegate>

@optional
/// 首次加载成功后,返回;仅返回一次
- (void)feedPage:(UIViewController *)vc
scrollViewcallback:(UIScrollView *)scrollView;
/// FeedPage 即将进入滑滑流视频
- (void)willEnterContentVideoFeedPage;

@end

NS_ASSUME_NONNULL_END
