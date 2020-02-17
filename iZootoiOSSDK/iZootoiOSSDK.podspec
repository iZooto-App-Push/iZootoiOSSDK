Pod::Spec.new do |spec|
  spec.name         = "iZootoiOSSDK"
  spec.version      = "1.0.1"
  spec.summary      = "iZooto Notification push services"
  spec.description  = " iZooto Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://github.com/izooto-mobile-sdk/iZootoiOSSDK"
  spec.license      = "MIT"
   spec.author      = { "AmitKumarGupta" => "amit@datability.co" }
  spec.ios.deployment_target  = '9.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iZootoiOSSDK.git", :tag => "1.0.1" }
  spec.source_files  = "iZootoiOSSDK/**/*"
  spec.exclude_files = "iZootoiOSSDK/**/*.plist"
  spec.requires_arc  = true

end
