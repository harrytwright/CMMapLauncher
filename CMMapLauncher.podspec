Pod::Spec.new do |s|
  s.name         = "CMMapLauncher"
  s.version      = "2.1.0"
  s.summary      = "CMMapLauncher is a mini-library for iOS that makes it quick and easy to show directions in various mapping applications."
  s.homepage     = "https://github.com/citymapper/CMMapLauncher"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = 'Citymapper'
  s.platform     = :ios
  s.source       = { :git => "https://github.com/citymapper/CMMapLauncher.git", :tag => "#{s.version}" }

  # Platform setup
  s.requires_arc            = true
  s.ios.deployment_target   = '10.0'

  # Exclude optional UI modules
  s.default_subspec = 'Core'

  ### Subspecs

  s.subspec 'Core' do |cs|
      cs.dependency     'CMMapLauncher/Launcher'
  end

  s.subspec 'Launcher' do |ls|
      ls.source_files   = 'CMMapLauncher/Launcher.h', 'CMMapLauncher/Launcher/**/*'
      ls.framework      = 'MapKit'
  end

  s.subspec 'UI' do |us|
      us.source_files   = 'CMMapLauncher/UI.h', 'CMMapLauncher/UI/**/*'
      us.dependency     'CMMapLauncher/Core'
  end

end
