Pod::Spec.new do |s|
  s.name           = 'SPiD-iOS-SDK'
  s.version        = '1.2.4'
  s.license        = 'MIT'
  s.summary        = 'SPiD iOS SDK.'
  s.homepage       = 'https://github.com/Aftonbladet/sdk-ios'
  s.authors        = { 'Mikael Lindström' => 'mikael.lindstrom@schibstedpayment.no', 'Maciej Walczynski' => 'maciej.walczynski@schibsted.pl', 'Marcel Hasselaar' => 'marcel.hasselaar@schibsted.se' }
  s.source         = { :git => 'https://github.com/Aftonbladet/sdk-ios.git', :branch => 'master' }
  s.description    = 'SPiDSDK for iOS.'
  s.platform       = :ios
  s.source_files   = 'SPiDSDK/**/*.{h,m}'
  s.frameworks     = 'Security'
  s.requires_arc   = true
end