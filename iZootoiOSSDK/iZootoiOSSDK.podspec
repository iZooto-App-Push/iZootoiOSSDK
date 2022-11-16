Pod::Spec.new do |spec|
  spec.name         = "iZootoiOSSDK"
  spec.version      = "2.0.6"
  spec.summary      = "iZooto Notification Push Services"
  spec.description  = " iZooto Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://www.izooto.com"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "AmitKumarGupta" => "amit@datability.co" }
  spec.platform     = :ios,"10"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iZootoiOSSDK.git", :tag => "2.0.6" }
  spec.source_files  = 'iZootoiOSSDK/**/*.{h,swift}'
  spec.exclude_files = 'iZootoiOSSDK/**/*.plist'
  spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'No' }
  spec.requires_arc  = true

end
