
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftCategoryUtil"

  spec.version      = "2.1.7.5"

  spec.summary      = "Swift版的链式编程，点语法，一条龙完成控件布局，最低支持IOS12 Swift5 "

  spec.description  = <<-DESC
  Swift版的链式编程，点语法，一条龙完成控件布局，最低支持IOS12 Swift5
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftCategoryUtil"
  
  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "13.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftCategoryUtil.git", :tag => spec.version }


  spec.subspec 'CoreUiit' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/CoreUiit/*.{swift}"
  end

  spec.subspec 'SwiftUI' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/SwiftUI/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
    ss.dependency "TFYSwiftCategoryUtil/Foundation"
    ss.dependency "TFYSwiftCategoryUtil/UIKit"
  end

  spec.subspec 'Base' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Base/*.{swift}"
  end

  spec.subspec 'Utils' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Utils/*.{swift}"
  end

  spec.subspec 'WKWeb' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/WKWeb/*.{swift}"
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
  end

  spec.subspec 'Gesture' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Gesture/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
    ss.dependency "TFYSwiftCategoryUtil/Utils"
  end
  
  spec.requires_arc = true

end
