//
//  BdAdLogoView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/16.
//

#import "BdAdLogoView.h"
#import "AdvanceAsset.h"

@interface BdAdLogoView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *adImageView;

@end

@implementation BdAdLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2;
    [self addSubview:self.logoImageView];
    [self addSubview:self.adImageView];
}

- (void)layoutSubviews {
    self.logoImageView.frame = CGRectMake(0, 0, 15, 14);
    self.adImageView.frame = CGRectMake(15, 0, 26, 14);
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.image = [AdvanceAsset bundleImageNamed:@"bdmob_adlogo"];
    }
    return _logoImageView;
}

-(UIImageView *)adImageView {
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc] init];
        _adImageView.contentMode = UIViewContentModeScaleAspectFit;
        _adImageView.image = [AdvanceAsset bundleImageNamed:@"bdmob_adIcon"];
    }
    return _adImageView;
}

@end
