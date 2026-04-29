Pod::Spec.new do |s|
  s.name             = 'NetworkKit'
  s.version          = '0.1.0'
  s.summary          = 'A network abstraction layer based on Moya.'
  s.description      = 'NetworkKit wraps Moya and exposes a stable request interface for Swift and mixed iOS apps.'
  s.homepage         = 'https://github.com/AidenL-Code/NetworkKit'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'Aiden' => 'AidenL-Code' }
  s.source           = { :git => 'git@github.com:AidenL-Code/NetworkKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.9'

  s.source_files = 'Sources/NetworkKit/**/*.{swift,h,m}'
  s.dependency 'Alamofire'
  s.dependency 'Moya'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/NetworkKitTests/**/*.swift'
  end
end
