Pod::Spec.new do |spec|
  spec.name         = "iZootoiOSSDK"
  spec.version      = "2.0.2"
  spec.summary      = "iZooto Notification Push Services"
  spec.description  = " iZooto Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://www.izooto.com"
  spec.license      = "MIT"
   spec.author      = { "AmitKumarGupta" => "amit@datability.co" }
  spec.platform     = :ios,"10"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iZootoiOSSDK.git", :tag => "2.0.2" }
  spec.source_files  = 'iZootoiOSSDK/**/*.{h,swift}'
  spec.exclude_files = 'iZootoiOSSDK/**/*.plist'
  spec.requires_arc  = true
  
end
