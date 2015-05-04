Pod::Spec.new do |s|

  s.name         = "SPiDSDK"
  s.version      = "1.2.8"
  s.summary      = "iOS SDK for using SPiD"

  s.description  = <<-DESC
  					This iOS SDK allows for a simpler interface to use the SPiD platform.
  					For more information see http://techdocs.spid.no/
                   DESC

  s.homepage     = "https://github.com/schibsted/sdk-ios"

  s.license      = "MIT"

  s.authors      = { "Mikael Lindström" => "mikael.lindstrom@schibsted.com", "Oskar Höjwall" => "oskar.hojwall@schibsted.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => 'https://github.com/schibsted/sdk-ios.git', :tag => '1.2.8' }

  s.source_files = "Classes", "SPiDSDK/**/*.{h,m}"

  s.frameworks = "Security"

  s.requires_arc = true

end
