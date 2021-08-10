Pod::Spec.new do |spec|
  spec.name         = "iZootoiOSSDK"
  spec.version      = "1.1.8"
  spec.summary      = "iZooto Notification push services"
  spec.description  = " iZooto Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://github.com/izooto-mobile-sdk/iZootoiOSSDK"
  spec.license      = "MIT"
   spec.author      = { "AmitKumarGupta" => "amit@datability.co" }
  spec.platform     = :ios,"10"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iZootoiOSSDK.git", :tag => "1.1.8" }
  spec.source_files  = 'iZootoiOSSDK/**/*.{h,swift}'
  spec.exclude_files = 'iZootoiOSSDK/**/*.plist'
  spec.requires_arc  = true
  
end
