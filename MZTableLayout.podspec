
Pod::Spec.new do |s|
  s.name             = 'MZTableLayout'
  s.version          = '1.2.0'
  s.swift_version    = '5.0'
  s.summary          = 'Free collection view layout like excel sheet.'

  s.description      = <<-DESC
Free collection view layout like excel sheet.
It's very easy to use.
                       DESC

  s.homepage         = 'https://github.com/MachelleZhang/MZTableLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangle' => '407916482@qq.com' }
  s.source           = { :git => 'https://github.com/MachelleZhang/MZTableLayout.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = '#{s.name.to_s}/*.swift'
  s.frameworks = 'UIKit', 'MapKit'
  
end
