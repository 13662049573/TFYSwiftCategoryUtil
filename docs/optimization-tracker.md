# TFYSwiftCategoryUtil 优化跟踪表

> 说明：按文件逐批推进，已完成的文件保留验证记录，避免后续遗漏。

| 状态 | 文件 | 本轮处理重点 | 验证 |
| --- | --- | --- | --- |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/CLLocation+Chain.swift` | 经纬度有限值校验、地址空白处理、方位角归一化、描述精度兜底 | 定向单测通过 |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/Timer+Chain.swift` | 非法时间间隔归一化、GCD Timer 毫秒精度、倒计时负数兜底、安全构造器回调稳定性 | 定向单测通过 |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/UIActivityIndicatorView+Chain.swift` | size 非负约束、alpha 范围约束、便捷构造隐藏策略统一 | 定向单测通过 |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/UIAlertController+Chain.swift` | 内部视图索引越界保护、内容高度/宽度/圆角/延迟参数兜底 | 定向单测通过 |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/UIApplication+Chain.swift` | 当前控制器安全查找、截图空尺寸兜底、App Store URL 清洗、启动时间修正 | 定向单测通过 |
| 已完成 | `TFYSwiftCategoryUtil/TFYSwiftCategoryUtil/UIKit/UIWindow+Chain.swift` | keyWindow 查找修正、iPad 刘海判断修正、圆角/阴影/动画/截图参数兜底 | 定向单测通过 |

## 验证记录

- 2026-06-02：`xcodebuild build -scheme TFYSwiftCategoryUtil -destination 'platform=iOS Simulator,id=AF3CD26A-34C6-47E1-9FE8-C36A55572702'` 通过。
- 2026-06-02：定向 `xcodebuild test` 两次均在加载 `TFYSwiftCategoryUtilTests.xctest` 时失败，错误为 `Trying to load an unsigned library`，未进入测试断言阶段。
- 2026-06-03：`xcodebuild build-for-testing -scheme TFYSwiftCategoryUtil -destination 'platform=iOS Simulator,id=AF3CD26A-34C6-47E1-9FE8-C36A55572702'` 通过。
- 2026-06-03：`UIAlertController`、`UIApplication`、`UIWindow` 三个新增定向测试通过。
- 2026-06-03：`CLLocation`、`Timer`、`UIActivityIndicatorView` 相关 5 个回归测试通过，旧签名阻塞已解除。
