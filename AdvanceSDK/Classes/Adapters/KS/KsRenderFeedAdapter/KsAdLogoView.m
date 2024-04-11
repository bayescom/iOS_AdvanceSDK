//
//  KsAdLogoView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "KsAdLogoView.h"
#import "AdvanceAsset.h"

@interface KsAdLogoView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoTextLabel;

@end

@implementation KsAdLogoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
    self.layer.cornerRadius = 2;
    [self addSubview:self.logoImageView];
    [self addSubview:self.logoTextLabel];
}

- (void)layoutSubviews {
    self.logoImageView.frame = CGRectMake(3, 2, 12, 12);
    self.logoTextLabel.frame = CGRectMake(19, 2, 21, 12);
}

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.image = [AdvanceAsset bundleImageNamed:@"ks_ad_logo_gray"];
    }
    return _logoImageView;
}

-(UILabel *)logoTextLabel {
    if (!_logoTextLabel) {
        _logoTextLabel = [[UILabel alloc] init];
        _logoTextLabel.font = [UIFont systemFontOfSize:10];
        _logoTextLabel.textColor = UIColor.whiteColor;
        _logoTextLabel.textAlignment = NSTextAlignmentCenter;
        _logoTextLabel.text = @"广告";
    }
    return _logoTextLabel;
}

@end
