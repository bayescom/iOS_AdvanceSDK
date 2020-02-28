#
# Be sure to run `pod lib lint AdvanceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AdvanceSDK'
  s.version          = '3.0.3'
  
  s.ios.deployment_target = '9.0'
  
  s.requires_arc = true
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.summary          = 'bayescom iOS SDK'
  s.description      = <<-DESC
Blink倍联——免费透明的流量变现神器 
600+ 移动媒体选择的广告商业化管理工具，定制私有的移动媒体商业化解决方案。优质上游资源一网打尽，接入方式快速透明稳定。支持流量分发、渠道策略、精准投放、数据报表、排期管理、广告审核等全流程业务场景。
                       DESC

  s.homepage         = 'http://www.bayescom.com/'
  
  s.author           = { 'bayescom' => 'http://www.bayescom.com/' }
  s.source           = { :git => 'https://github.com/bayescom/AdvanceSDK.git', :tag => s.version.to_s }
   
  s.user_target_xcconfig = {'OTHER_LDFLAGS' => ['-ObjC']}
   
  # bitcode
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  s.user_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.default_subspec = 'Core', 'Mercury'
  

  s.subspec 'Core' do |core|
    core.vendored_frameworks = 'AdvanceSDK/Core/*.framework'
    core.requires_arc = true
    core.frameworks = 'UIKit', 'Foundation', 'AdSupport', 'CoreLocation'
    core.libraries     = 'z', 'sqlite3', 'c++', 'resolv.9', 'xml2'
  end

  s.subspec 'Mercury' do |mercury|
    mercury.dependency 'MercurySDK', '~> 3.0.2'
  end

  s.subspec 'CSJ' do |csj|
    csj.dependency 'Bytedance-UnionAD', '~> 2.7.5.2'
  end

  s.subspec 'GDT' do |gdt|
    gdt.dependency 'GDTMobSDK', '~> 4.11.2'
  end

end
