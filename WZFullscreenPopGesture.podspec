Pod::Spec.new do |s|

  s.name             = 'WZFullscreenPopGesture'
  s.version          = '1.3.0'
  s.summary          = '左滑手势'

  s.description      = <<-DESC
    我主良缘技有限公司,iOS项目组滑屏组件.
                       DESC

  s.homepage         = 'https://github.com/WZLYiOS/WZFullscreenPopGesture'
  s.license          = 'MIT'
  s.author           = { 'qixiang qiu'=> '327847390@qq.com' }
  s.source           = { :git => 'https://github.com/WZLYiOS/WZFullscreenPopGesture.git', :tag => s.version.to_s }
  
  s.swift_version         = '5.0'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.source_files = 'WZFullscreenPopGesture/Core/'
end

