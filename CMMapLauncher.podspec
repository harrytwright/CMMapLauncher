Pod::Spec.new do |s|
  s.name         = "CMMapLauncher"
  s.version      = "2.0.0"
  s.summary      = "CMMapLauncher is a mini-library for iOS that makes it quick and easy to show directions in various mapping applications."
  s.homepage     = "https://github.com/citymapper/CMMapLauncher"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = 'Citymapper'
  s.platform     = :ios
  s.source       = { :git => "https://github.com/citymapper/CMMapLauncher.git", :tag => "1.1.0" }
  s.source_files  = 'CMMapLauncher'
  s.ios.deployment_target  = '10.0'
  s.framework  = 'MapKit'
  s.requires_arc = true
end
