# TFYSwiftCategoryUtil

[![Platforms](https://img.shields.io/badge/Platforms-iOS-orange.svg)](https://github.com/13662049573/TFYSwiftCategoryUtil)
[![Version](https://img.shields.io/cocoapods/v/TFYSwiftCategoryUtil.svg)](https://cocoapods.org/pods/TFYSwiftCategoryUtil)
[![License](https://img.shields.io/cocoapods/l/TFYSwiftCategoryUtil.svg)](https://github.com/13662049573/TFYSwiftCategoryUtil/blob/master/LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-12.0+-blue.svg)](https://developer.apple.com/xcode)
[![iOS](https://img.shields.io/badge/iOS-13.0+-green.svg)](https://ios.com)

TFYSwiftCategoryUtil 是一个功能丰富的 Swift 工具库，提供了大量实用的扩展和工具类，帮助开发者更高效地进行 iOS 开发。采用链式编程风格，让代码更简洁优雅。

## ✨ 特性

- 🔗 优雅的链式编程支持
- 📱 丰富的 UIKit 组件扩展
- 🎨 SwiftUI 相关工具和扩展
- 🛠 实用的工具类集合
- 🌐 WKWebView 相关功能增强
- 👆 手势识别相关扩展
- 📚 完整的文档和示例

## 📦 安装

### CocoaPods

```ruby
pod 'TFYSwiftCategoryUtil'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftCategoryUtil.git", .upToNextMajor(from: "2.1.9.5"))
]
```

## 🌟 主要模块

### 基础模块 (Base)
- Chain - 链式编程核心结构
- HasFont - 字体相关协议
- HasText - 文本处理协议

### UI 扩展 (UIKit)
- UIView 扩展
  - frame 设置
  - 圆角、阴影
  - 渐变背景
  - 边框样式
  - 动画效果
- UIButton 扩展
  - 图文布局
  - 点击事件
  - 倒计时功能
  - 点击区域扩展
- UILabel 扩展
  - 富文本设置
  - 行间距调整
  - 文本渐变
  - 描边效果
- UITableView/UICollectionView 扩展
  - 注册复用
  - 空数据展示
  - 刷新控件
- 更多 UI 组件扩展...

### SwiftUI 工具
- 视图修饰器
- 绑定工具
- 自定义视图组件
- 动画效果
- 底部弹窗
- 闪光效果

### 工具类 (Utils)
- 异步操作 (TFYAsynce)
- 网络状态监测 (TFYNetstatManager) 
- 正则表达式 (TFYRegexHelper)
- Runtime 工具 (TFYRuntime)
- 图片处理 (TFYStitchImage)
- JSON 解析 (TFYSwiftJsonKit)
- 弹窗工具 (TFYSwiftPopupView)
- 定时器 (TFYTimer)

### WKWebView 增强
- 参数编解码
- 脚本处理
- 布局控制
- 代理封装
- Cookie 管理
- 进度监听

## 📝 使用示例

### 链式编程

```swift
// UILabel 示例
let label = UILabel()
    .tfy
    .text("Hello")
    .textColor(.black)
    .font(.systemFont(ofSize: 16))
    .textAlignment(.center)
    .numberOfLines(0)
    .backgroundColor(.white)
    .cornerRadius(8)
    .base

// UIButton 示例
let button = UIButton()
    .tfy
    .title("Click Me", for: .normal)
    .titleColor(.white, for: .normal)
    .backgroundColor(.systemBlue)
    .cornerRadius(5)
    .borderWidth(1)
    .borderColor(.blue)
    .onTap { 
        print("Button tapped")
    }
    .base

// UIView 渐变示例
let gradientView = UIView()
    .tfy
    .frame(CGRect(x: 0, y: 0, width: 200, height: 50))
    .gradientColor(colors: [.red, .blue], 
                  start: CGPoint(x: 0, y: 0),
                  end: CGPoint(x: 1, y: 1))
    .base
```

### SwiftUI 扩展

```swift
struct ContentView: View {
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Text("Hello")
                .addShimmer(isActive: true)
            
            Button("Show Sheet") {
                showSheet.toggle()
            }
            .addBottomSheet(isPresented: $showSheet) {
                SheetContent()
            }
        }
        .navigationBarColor(backgroundColor: .blue, 
                          titleColor: .white)
    }
}
```

### 工具类使用

```swift
// 异步操作
TFYAsynce.async {
    // 后台任务
} mainBlock: {
    // 主线程更新 UI
}

// 正则验证
let isEmail = "test@example.com".tfy.isValidEmail
let isPhone = "13800138000".tfy.isValidPhone

// JSON 解析
let model: YourModel = try TFYSwiftJsonKit.model(from: jsonData)

// 图片处理
let image = UIImage(named: "original")
let processed = image?.tfy
    .resize(to: CGSize(width: 100, height: 100))
    .cornerRadius(10)
    .addWatermark(text: "TFY")
    .base

// 定时器
TFYTimer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
    // 定时执行的代码
}
```

## 🔧 系统要求

- iOS 15.0+
- Swift 5.0+
- Xcode 14.0+

## 📋 待办事项

- [ ] SwiftUI 组件库扩展
- [ ] Combine 框架集成
- [ ] 单元测试覆盖
- [ ] 性能优化
- [ ] 文档完善

## 👨‍💻 作者

田风有 13662049573@163.com

## 📄 许可证

TFYSwiftCategoryUtil 基于 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=13662049573/TFYSwiftCategoryUtil&type=Date)](https://star-history.com/#13662049573/TFYSwiftCategoryUtil&Date)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request。

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

