Pod::Spec.new do |spec|
  spec.name         = 'SPiD iOS SDK'
  spec.version      = '1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/schibsted/sdk-ios'
  spec.authors      = { 'Mikael Lindström' => 'mikael.lindstrom@schibsted.com', 'Oskar Höjwall' => 'oskar.hojwall@schibsted.com' }
  spec.summary      = 'SPiD SDK for the iOS platform'
  spec.source       = { :git => 'https://github.com/schibsted/sdk-ios.git', :tag => '1.2.5' }
  spec.source_files = 'SPiDSDK/*.{m,h}'
  spec.requires_arc      = true
end
