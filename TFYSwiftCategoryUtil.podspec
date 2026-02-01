
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftCategoryUtil"

  spec.version      = "2.4.1"

  spec.summary      = "Swift版的链式编程，点语法，一条龙完成控件布局，最低支持IOS15 Swift5 "

  spec.description  = <<-DESC
  TFYSwiftCategoryUtil 是一个功能丰富的 Swift 工具库，提供了大量实用的扩展和工具类，帮助开发者更高效地进行 iOS 开发。采用链式编程风格，让代码更简洁优雅。支持 iPhone 和 iPad 适配，最低支持 iOS 15.0+。

  主要特性：
  - 🔗 优雅的链式编程支持
  - 📱 丰富的 UIKit 组件扩展
  - 🎨 完整的屏幕适配方案（iPhone/iPad）
  - 🛠 实用的工具类集合
  - 🌐 WKWebView 相关功能增强
  - 👆 手势识别相关扩展
  - 🎭 强大的弹窗系统
  - 📍 位置服务工具
  - 🔄 响应式编程支持
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftCategoryUtil"
  
  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "15.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftCategoryUtil.git", :tag => spec.version }


  spec.subspec 'CoreUiit' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/CoreUiit/*.{swift}"
  end

  spec.subspec 'Base' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Base/*.{swift}"
  end

  spec.subspec 'Utils' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Utils/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
  end

  spec.subspec 'WKWeb' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/WKWeb/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
  end

  spec.subspec 'UIKit' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
  end

  spec.subspec 'Foundation' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Foundation/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
    ss.dependency "TFYSwiftCategoryUtil/UIKit"
    ss.dependency "TFYSwiftCategoryUtil/CoreUiit"
    ss.dependency "TFYSwiftCategoryUtil/Gesture"
  end

  spec.subspec 'Gesture' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Gesture/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
  end
  
  spec.requires_arc = true

end
