//
//  AdvanceAsset.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/11.
//

#import "AdvanceAsset.h"

@implementation AdvanceAsset

+ (NSBundle *)hostBundle {
    NSBundle *podBundle = [NSBundle bundleForClass:AdvanceAsset.class];
    NSURL *bundleURL = [podBundle URLForResource:@"AdvanceSDK" withExtension:@"bundle"];
    if (bundleURL) {
        return [NSBundle bundleWithURL:bundleURL];
    }
    return podBundle;
}

+ (UIImage *)bundleImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name inBundle:[self hostBundle] compatibleWithTraitCollection:nil];
    return image;
}

@end
