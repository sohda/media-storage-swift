Pod::Spec.new do |s|
  s.name         = "RicohAPIMStorage"
  s.version      = "2.0.0"
  s.summary      = "Ricoh Media Storage API Client"
  s.description  = "Ricoh Media Storage API Client in Swift"
  s.homepage     = "https://github.com/ricohapi/media-storage-swift"
  s.license      = "MIT"
  s.author       = "Ricoh Company, Ltd."

  s.source      = { :git => "https://github.com/ricohapi/media-storage-swift.git", :tag => "v#{s.version}" }
  s.source_files  = "Source/*.swift"

  s.ios.deployment_target = "9.0"

  s.dependency "RicohAPIAuth", "~> 1.0.1"
end
