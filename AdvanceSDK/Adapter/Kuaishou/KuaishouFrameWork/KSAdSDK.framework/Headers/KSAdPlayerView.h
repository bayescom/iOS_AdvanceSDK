//
//  KSAdPlayerView.h
//  KSAdPlayer
//
//  Created by 徐志军 on 2019/10/10.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KSAdBasePlayerView.h"


@interface KSAdPlayerView : KSAdBasePlayerView

//是否上报播放Ns日志，默认YES
@property (nonatomic, assign) BOOL shouldReportPlayNs;

@property (nonatomic, assign ,readonly) BOOL playerErrorStatus;

@end
