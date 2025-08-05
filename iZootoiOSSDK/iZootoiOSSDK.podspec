Pod::Spec.new do |spec|
  spec.name         = "iZootoiOSSDK"
  spec.version      = "2.4.6-beta3"
  spec.summary      = "iZooto Notification Push Services"
  spec.description  = " iZooto Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://www.izooto.com"
  spec.license      = "MIT"
   spec.author      = { "AmitKumarGupta" => "amit@datability.co" }
  spec.platform     = :ios,"12"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iZootoiOSSDK.git", :tag => "2.4.6-beta3" }
  spec.source_files  = 'iZootoiOSSDK/**/*.{h,swift}'
  spec.exclude_files = 'iZootoiOSSDK/iZootoiOSSDK/iZootoiOSSDK/Source/iZooto/UserPropertyManager.swift'

  spec.exclude_files = 'iZootoiOSSDK/**/*.plist'
  spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'No' }
  spec.requires_arc  = true
  
end
