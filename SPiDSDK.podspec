Pod::Spec.new do |s|
  s.name         = "SPiDSDK"
  s.version      = "2.4.1"
  s.summary      = "iOS SDK for using SPiD"
  s.description  = <<-DESC
  					This iOS SDK allows for a simpler interface to use the SPiD platform.
  					For more information see http://techdocs.spid.no/
                   DESC
  s.homepage     = "https://github.com/schibsted/SPiDSDK"
  s.license      = "MIT"
  s.authors      = { "Mikael Lindström" => "mikael.lindstrom@schibsted.com", "Oskar Höjwall" => "oskar.hojwall@schibsted.com" }
  s.source       = { :git => 'https://github.com/schibsted/SPiDSDK.git', :tag => s.version.to_s }


  s.frameworks = "Security"
  s.requires_arc = true

  s.ios.source_files = "Sources/*.{h,m}", "SPiDSDK/iOS/*{.h,m}"
  s.tvos.source_files = "Sources/*.{h,m}"
  s.watchos.source_files = "Sources/*.{h,m}"

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
end
