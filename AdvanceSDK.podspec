#
# Be sure to run `pod lib lint AdvanceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
    s.name             = 'AdvanceSDK'
    s.version          = '5.0.2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.summary          = 'bayescom iOS AdvanceSDK'
    s.description      = <<-DESC
    Blink倍联——免费透明的流量变现神器 
    600+ 移动媒体选择的广告商业化管理工具，定制私有的移动媒体商业化解决方案。优质上游资源一网打尽，接入方式快速透明稳定。支持流量分发、渠道策略、精准投放、数据报表、排期管理、广告审核等全流程业务场景。
    DESC
    
    s.homepage         = 'http://www.bayescom.com/'
    s.author           = { 'bayescom' => 'http://www.bayescom.com/' }
    s.source           = { :git => 'https://github.com/bayescom/AdvanceSDK.git', :tag => s.version.to_s }
    
    s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
    s.platform     = :ios, "10.0"
    s.requires_arc = true
    s.static_framework = true
    
    # 默认的使用模块
    s.default_subspec = 'Core'
    
    s.subspec 'Core' do |core|
        core.source_files = 'AdvanceSDK/Core/**/*.{h,m}'
        core.frameworks = 'UIKit', 'Foundation', 'AdSupport'
    end
    
    s.subspec 'AdSpot' do |adSpot|
        adSpot.dependency 'AdvanceSDK/Core'
        adSpot.source_files = 'AdvanceSDK/AdSpot/**/*.{h,m}'
    end
    
    s.subspec 'MercuryAdapter' do |mer|
        mer.dependency 'AdvanceSDK/Core'
        mer.dependency 'AdvanceSDK/AdSpot'
        mer.dependency 'MercurySDK'
        mer.source_files = 'AdvanceSDK/Adapters/Mercury/**/*.{h,m}'
    end
    
    # 基于穿山甲单独SDK
    s.subspec 'CSJAdapter' do |csj|
        csj.dependency 'AdvanceSDK/Core'
        csj.dependency 'AdvanceSDK/AdSpot'
        csj.dependency 'Ads-CN'
        csj.source_files = 'AdvanceSDK/Adapters/CSJ/**/*.{h,m}'
        csj.frameworks = 'UIKit', 'MapKit', 'WebKit', 'MediaPlayer', 'CoreLocation', 'AdSupport', 'CoreMedia', 'AVFoundation', 'CoreTelephony', 'StoreKit', 'SystemConfiguration', 'MobileCoreServices', 'CoreMotion', 'Accelerate','AudioToolbox','JavaScriptCore','Security','CoreImage','AudioToolbox','ImageIO','QuartzCore','CoreGraphics','CoreText'
        csj.libraries = 'c++', 'resolv', 'z', 'sqlite3', 'bz2', 'xml2', 'iconv', 'c++abi'
        csj.weak_frameworks = 'AppTrackingTransparency', 'DeviceCheck'
    end
    
    # 基于穿山甲融合SDK
    s.subspec 'CSJAdapter-Fusion' do |csj|
        csj.dependency 'AdvanceSDK/Core'
        csj.dependency 'AdvanceSDK/AdSpot'
        csj.dependency 'Ads-Fusion-CN-Beta/BUAdSDK'
        csj.source_files = 'AdvanceSDK/Adapters/CSJ/**/*.{h,m}'
        csj.frameworks = 'UIKit', 'MapKit', 'WebKit', 'MediaPlayer', 'CoreLocation', 'AdSupport', 'CoreMedia', 'AVFoundation', 'CoreTelephony', 'StoreKit', 'SystemConfiguration', 'MobileCoreServices', 'CoreMotion', 'Accelerate','AudioToolbox','JavaScriptCore','Security','CoreImage','AudioToolbox','ImageIO','QuartzCore','CoreGraphics','CoreText'
        csj.libraries = 'c++', 'resolv', 'z', 'sqlite3', 'bz2', 'xml2', 'iconv', 'c++abi'
        csj.weak_frameworks = 'AppTrackingTransparency', 'DeviceCheck'
    end
    
    s.subspec 'GDTAdapter' do |gdt|
        gdt.dependency 'AdvanceSDK/Core'
        gdt.dependency 'AdvanceSDK/AdSpot'
        gdt.dependency 'GDTMobSDK'
        gdt.source_files =  'AdvanceSDK/Adapters/GDT/**/*.{h,m}'
        gdt.frameworks = 'AdSupport', 'CoreLocation', 'QuartzCore', 'SystemConfiguration', 'CoreTelephony', 'Security', 'StoreKit', 'AVFoundation'
        gdt.libraries     = 'xml2', 'z'
        gdt.weak_frameworks = 'WebKit'
    end
     
    s.subspec 'KSAdapter' do |ks|
        ks.dependency 'AdvanceSDK/Core'
        ks.dependency 'AdvanceSDK/AdSpot'
        ks.dependency 'KSAdSDK'
        ks.source_files = 'AdvanceSDK/Adapters/KS/**/*.{h,m}'
        ks.frameworks = ["Foundation", "UIKit", "MobileCoreServices", "CoreGraphics", "Security", "SystemConfiguration", "CoreTelephony", "AdSupport", "CoreData", "StoreKit", "AVFoundation", "MediaPlayer", "CoreMedia", "WebKit", "Accelerate", "CoreLocation", "AVKit", "MessageUI", "QuickLook", "AudioToolBox", "AddressBook"]
        ks.libraries =  ["z", "resolv.9", "sqlite3", "c++", "c++abi"]
    end
    
    s.subspec 'BDAdapter' do |bd|
        bd.dependency 'AdvanceSDK/Core'
        bd.dependency 'AdvanceSDK/AdSpot'
        bd.dependency 'BaiduMobAdSDK'
        bd.source_files =  'AdvanceSDK/Adapters/BD/**/*.{h,m}'
        bd.frameworks = 'CoreLocation', 'SystemConfiguration', 'CoreGraphics', 'CoreMotion', 'CoreTelephony', 'AdSupport', 'SystemConfiguration', 'QuartzCore', 'WebKit', 'MessageUI','SafariServices','AVFoundation','EventKit','QuartzCore','CoreMedia','StoreKit'
        bd.libraries     = 'c++'
    end
    
    s.subspec 'GroMoreBidding' do |bidding|
        bidding.dependency 'AdvanceSDK/Core'
        bidding.dependency 'AdvanceSDK/AdSpot'
        bidding.dependency 'GroMoreBiddingSDK', '1.2.0'
        bidding.source_files = 'AdvanceSDK/GroMoreBidding/**/*.{h,m}'
    end

end
