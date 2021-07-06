//
//  KSAdImage.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/10/14.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSAdImage : NSObject
// image address URL
@property (nonatomic, copy) NSString *imageURL;

@property (nonatomic, strong, nullable) UIImage *image;

// image width
@property (nonatomic, assign) float width;

// image height
@property (nonatomic, assign) float height;
@end

NS_ASSUME_NONNULL_END
