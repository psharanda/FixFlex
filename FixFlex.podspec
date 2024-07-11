Pod::Spec.new do |s|
  s.name         = "FixFlex"
  s.version      = "1.2.3"
  s.summary      = "Declarative Auto Layout code that is easy to write, read, and modify"
  s.description  = <<-DESC
    `FixFlex` is a simple yet powerful Auto Layout library built on top of the NSLayoutAnchor API, a swifty and type-safe reimagination of Visual Format Language
  DESC
  s.homepage     = "https://github.com/psharanda/FixFlex"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Pavel Sharanda" => "psharanda@gmail.com" }
  s.social_media_url   = "https://twitter.com/psharanda"
  s.swift_version = '5.1'
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "12.0"
  s.source       = { :git => "https://github.com/psharanda/FixFlex.git", :tag => s.version.to_s }
  s.source_files = "Sources/**/*.swift"
end
