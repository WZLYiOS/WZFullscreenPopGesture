#
# Be sure to run `pod lib lint WZFullscreenPopGesture.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html


Pod::Spec.new do |s|
  s.name             = 'WZFullscreenPopGesture'
  s.version          = '6.1.2'
  s.summary          = 'A short description of WZFullscreenPopGesture.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try 
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/WZLYiOS/WZFullscreenPopGesture'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'qiuqixiang' => '739140860@qq.com' }
  s.source           = { :git => 'https://github.com/WZLYiOS/WZFullscreenPopGesture.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_version         = '5.0'
  s.requires_arc = true

  s.source_files = 'WZFullscreenPopGesture/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WZFullscreenPopGesture' => ['WZFullscreenPopGesture/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
end
