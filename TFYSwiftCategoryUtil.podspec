
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftCategoryUtil"

  spec.version      = "2.0.2"

  spec.summary      = "Swift版的链式编程，点语法，一条龙完成控件布局，最低支持IOS13 Swift5 "

  spec.description  = <<-DESC
  Swift版的链式编程，点语法，一条龙完成控件布局，最低支持IOS13 Swift5
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftCategoryUtil"
  
  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.platform     = :ios, "13.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftCategoryUtil.git", :tag => spec.version }


  spec.subspec 'Base' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Base/*.{swift}"
  end

  spec.subspec 'Utils' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Utils/*.{swift}"
  end

  spec.subspec 'Category' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Category/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
  end

  spec.subspec 'Foundation' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Foundation/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
  end

  spec.subspec 'Gesture' do |ss|
    ss.source_files  = "TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/Gesture/*.{swift}"
    ss.dependency "TFYSwiftCategoryUtil/Base"
  end
  
  spec.requires_arc = true

  # spec.resources = "RWPickFlavor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"
  
end
