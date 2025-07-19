# TFY 通用链式生成器

一个完全通用的链式编程工具生成器，可以自动分析任何 Objective-C/Swift 类的属性、方法等，并生成对应的链式扩展代码。

## 特性

- 🚀 **完全通用**：不依赖任何特定的链式编程框架
- 🔍 **运行时分析**：自动分析类的属性、方法、变量等
- ⚙️ **高度可配置**：支持自定义过滤规则、映射规则等
- 📝 **自动生成**：生成完整的链式扩展代码
- 🎯 **类型安全**：生成的代码完全类型安全
- 📦 **批量生成**：支持批量生成多个类的链式扩展
- 💾 **文件保存**：支持将生成的代码保存到文件

## 安装

将 `TFYChainGenerator.swift` 文件添加到您的项目中即可使用。

## 基本使用

### 1. 生成单个类的链式扩展

```swift
import Foundation

// 创建生成器实例
let generator = TFYChainGenerator.shared

// 生成 UIView 的链式扩展
let uiviewCode = generator.generateUIViewChain()
print(uiviewCode)

// 生成自定义类的链式扩展
let customCode = generator.generateChainExtension(for: "MyCustomClass")
print(customCode)
```

### 2. 使用自定义配置

```swift
// 创建自定义配置
var config = TFYChainGeneratorConfig()
config.includeReadOnlyProperties = true
config.includePrivateProperties = false
config.includeSystemMethods = false
config.includeInheritedProperties = true

// 自定义属性过滤
config.propertyFilter = { name, type in
    // 只包含特定类型的属性
    let allowedTypes = ["UIColor", "CGRect", "CGFloat", "Bool", "String"]
    return allowedTypes.contains(type)
}

// 自定义属性映射
config.propertyMapping = [
    "backgroundColor": "bgColor",
    "frame": "rect"
]

// 生成自定义链式扩展
let customCode = generator.generateChainExtension(for: "UIView", config: config)
```

### 3. 批量生成

```swift
// 批量生成多个类的链式扩展
let classNames = ["UIView", "UIButton", "UILabel", "UITextField"]
let batchCode = generator.generateChainExtensions(for: classNames)
```

### 4. 保存到文件

```swift
// 生成并保存到文件
let success = generator.generateAndSave(
    for: "UIView", 
    to: "/path/to/UIView+Chain.swift"
)
```

## 生成的代码结构

生成的代码包含以下部分：

### 1. 链式包装器

```swift
public struct UIViewChain {
    private let base: UIView
    
    public init(_ base: UIView) {
        self.base = base
    }
    
    public var build: UIView { return base }
}
```

### 2. 链式协议

```swift
public protocol UIViewChainCompatible {}

public extension UIViewChainCompatible where Self: UIView {
    var chain: UIViewChain { UIViewChain(self) }
}
```

### 3. 链式扩展

```swift
public extension UIViewChain {
    
    /// 设置 backgroundColor
    /// - Parameter backgroundColor: Property: backgroundColor of type UIColor
    /// - Returns: 链式调用对象
    @discardableResult
    func backgroundColor(_ backgroundColor: UIColor) -> UIViewChain {
        base.backgroundColor = backgroundColor
        return self
    }
    
    /// 设置 frame
    /// - Parameter frame: Property: frame of type CGRect
    /// - Returns: 链式调用对象
    @discardableResult
    func frame(_ frame: CGRect) -> UIViewChain {
        base.frame = frame
        return self
    }
}
```

## 使用生成的链式代码

### 基本使用

```swift
// 创建视图
let view = UIView()

// 链式调用
view.chain
    .backgroundColor(.red)
    .frame(CGRect(x: 0, y: 0, width: 100, height: 100))
    .alpha(0.8)
    .isHidden(false)
    .build  // 获取最终对象
```

### 获取结果

```swift
// 直接获取配置后的对象
let configuredView = view.chain
    .backgroundColor(.blue)
    .frame(CGRect(x: 10, y: 10, width: 200, height: 100))
    .build
```

### 条件设置

```swift
// 条件链式调用
if isDarkMode {
    view.chain
        .backgroundColor(.darkGray)
        .alpha(0.9)
} else {
    view.chain
        .backgroundColor(.lightGray)
        .alpha(1.0)
}
```

## 配置选项

### TFYChainGeneratorConfig

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `includeReadOnlyProperties` | `Bool` | `false` | 是否包含只读属性 |
| `includePrivateProperties` | `Bool` | `false` | 是否包含私有属性 |
| `includeSystemMethods` | `Bool` | `false` | 是否包含系统方法 |
| `includePrivateMethods` | `Bool` | `false` | 是否包含私有方法 |
| `includeInheritedProperties` | `Bool` | `true` | 是否包含继承的属性 |
| `includeInheritedMethods` | `Bool` | `true` | 是否包含继承的方法 |
| `includeComments` | `Bool` | `true` | 是否包含注释 |
| `includeDocumentation` | `Bool` | `true` | 是否包含文档注释 |
| `propertyFilter` | `((String, String) -> Bool)?` | `nil` | 属性过滤规则 |
| `methodFilter` | `((String, [String]) -> Bool)?` | `nil` | 方法过滤规则 |
| `propertyMapping` | `[String: String]` | `[:]` | 属性名称映射 |
| `methodMapping` | `[String: String]` | `[:]` | 方法名称映射 |

### 过滤规则示例

```swift
// 属性过滤：只包含特定类型的属性
config.propertyFilter = { name, type in
    let allowedTypes = ["UIColor", "CGRect", "CGFloat", "Bool", "String"]
    return allowedTypes.contains(type)
}

// 方法过滤：只包含无参数或单参数的方法
config.methodFilter = { name, parameterTypes in
    return parameterTypes.count <= 1
}
```

### 映射规则示例

```swift
// 属性名称映射
config.propertyMapping = [
    "backgroundColor": "bgColor",
    "frame": "rect",
    "alpha": "opacity"
]

// 方法名称映射
config.methodMapping = [
    "setNeedsLayout": "needsLayout",
    "setNeedsDisplay": "needsDisplay"
]
```

## 高级功能

### 1. 运行时分析

```swift
// 使用运行时工具分析类
let properties = TFYRuntimeUtils.getProperties(for: UIView.self)
let methods = TFYRuntimeUtils.getMethods(for: UIView.self)

print("属性数量: \(properties.count)")
print("方法数量: \(methods.count)")
```

### 2. 错误处理

```swift
// 生成器会自动处理类不存在的情况
let code = generator.generateChainExtension(for: "NonExistentClass")
// 会生成错误提示代码
```

### 3. 性能优化

```swift
// 避免在运行时频繁生成代码
// 建议预生成常用的链式扩展并缓存结果
let cachedCode = generator.generateUIViewChain()
// 将 cachedCode 保存到文件中，在需要时直接使用
```

## 最佳实践

### 1. 项目集成

```swift
// 在项目初始化时生成常用的链式扩展
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 生成常用的链式扩展
        let generator = TFYChainGenerator.shared
        
        // 生成并保存到项目目录
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let chainPath = "\(documentsPath)/ChainExtensions"
        
        // 确保目录存在
        try? FileManager.default.createDirectory(atPath: chainPath, withIntermediateDirectories: true)
        
        // 生成常用UI控件的链式扩展
        let uiClasses = ["UIView", "UIButton", "UILabel", "UITextField", "UIImageView"]
        for className in uiClasses {
            let filePath = "\(chainPath)/\(className)+Chain.swift"
            _ = generator.generateAndSave(for: className, to: filePath)
        }
        
        return true
    }
}
```

### 2. 自定义配置

```swift
// 为不同类型的类创建不同的配置
extension TFYChainGenerator {
    
    /// 生成UI控件的链式扩展
    func generateUIControlChain(for className: String) -> String {
        var config = TFYChainGeneratorConfig()
        config.includeReadOnlyProperties = false
        config.includePrivateProperties = false
        config.includeSystemMethods = false
        config.propertyFilter = { name, type in
            // 过滤掉一些不需要的属性
            let excludedProperties = ["layer", "superview", "window", "next"]
            return !excludedProperties.contains(name)
        }
        
        return generateChainExtension(for: className, config: config)
    }
    
    /// 生成数据模型的链式扩展
    func generateModelChain(for className: String) -> String {
        var config = TFYChainGeneratorConfig()
        config.includeReadOnlyProperties = true
        config.includePrivateProperties = false
        config.includeSystemMethods = false
        config.includeInheritedProperties = true
        
        return generateChainExtension(for: className, config: config)
    }
}
```

### 3. 团队协作

```swift
// 在团队中统一链式扩展的命名规范
extension TFYChainGenerator {
    
    /// 生成符合团队规范的链式扩展
    func generateTeamStandardChain(for className: String) -> String {
        var config = TFYChainGeneratorConfig()
        
        // 团队统一的属性映射
        config.propertyMapping = [
            "backgroundColor": "bgColor",
            "textColor": "textColor",
            "font": "font",
            "text": "text"
        ]
        
        // 团队统一的方法映射
        config.methodMapping = [
            "setNeedsLayout": "needsLayout",
            "setNeedsDisplay": "needsDisplay"
        ]
        
        return generateChainExtension(for: className, config: config)
    }
}
```

## 注意事项

1. **性能考虑**：避免在运行时频繁生成代码，建议预生成并缓存
2. **内存管理**：生成的代码会自动处理内存管理
3. **类型安全**：生成的代码完全类型安全，编译时检查
4. **向后兼容**：生成的代码与原始类完全兼容
5. **错误处理**：生成器会自动处理类不存在等错误情况

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### v1.0.0
- 初始版本
- 支持基本的链式扩展生成
- 支持自定义配置和过滤规则
- 支持批量生成和文件保存 