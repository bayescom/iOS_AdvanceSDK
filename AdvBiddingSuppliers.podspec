
Pod::Spec.new do |spec|

  spec.name         = "AdvBiddingSuppliers"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of AdvBiddingSuppliers."

  spec.description  = <<-DESC
                   DESC

  spec.homepage     = "https://github.com/shichuanyang/AdvBiddingSuppliers"


  spec.license      = { :type => 'MIT', :file => 'LICENSE' }



  spec.author             = { "shichuanyang" => "shicy@bayescom.com" }


  spec.platform     = :ios
  spec.platform     = :ios, "12.0"


  spec.source       = { :git => "https://github.com/shichuanyang/AdvBiddingSuppliers.git", :tag => s.version.to_s }

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"


  spec.ios.vendored_frameworks = ['Classes/ABUAdAdmobAdapter.framework','Classes/ABUAdBaiduAdapter.framework','Classes/ABUAdCsjAdapter.framework', 'Classes/ABUAdGdtAdapter.framework','Classes/ABUAdKlevinAdapter.framework','Classes/ABUAdMintegralAdapter.framework','Classes/ABUAdUnityAdapter.framework','Classes/ABUVisualDebug.framework','Classes/ABUAdSDK.framework','Classes/ABUAdSigmobAdapter.framework']


  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
