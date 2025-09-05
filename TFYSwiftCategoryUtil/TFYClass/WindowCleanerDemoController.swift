//
//  WindowCleanerDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFY on 2024
//
//  WindowCleanerDemoController - Window清理工具演示控制器
//
//  功能说明：
//  - 演示TFYWindowCleaner的各种使用方法
//  - 展示不同类型的清理操作
//  - 展示链式调用和配置选项
//  - 展示动画清理效果
//  - 展示内存清理和重置功能
//  - 展示错误处理和性能监控
//  - 展示批量清理和状态管理
//

import UIKit

class WindowCleanerDemoController: UIViewController {
    
    let artitleDict:[String:String] = ["مكافأة مكافأة":"wwww.baidu.com","عمليات تسجيل الدخول":"wwww.baidu.com","48 ساعة":"wwww.baidu.com"]
    let arTitle:String = #"""
1. بعد الشراء الناجح، إذا لم تقم بتسجيل الدخول اليوم، يرجى زيارة صفحة تسجيل الدخول للمطالبة بعلاوتك اليومية. إذا قمت بالدخول بالفعل، سيتم تقييد علاوتك تلقائيًا في حسابك. يمكنك التحقق منه في القسم "مكافأة مكافأة".
2. على سبيل المثال: أسبوعياً، تتلقى 1500 قطعة نقدية على الفور عند الشراء. احصل على 80 قطعة نقدية إضافية لعمليات الفحص اليومية على مدى 7 أيام متتالية، بمجموع 2060؛ شهرياً، تتلقى 2500 قطعة نقدية على الفور عند الشراء. احصل على 120 عملة إضافية مقابل عمليات تسجيل الدخول اليومية على مدى 30 يوماً متتالياً، بمجموع 6100 دولار. تسود المكافآت الفعلية الممنوحة.
3. إذا لم تسجل الدخول للحصول على المكافأة المقابلة في نفس اليوم، فلا يمكن المطالبة بالمكافآت بأثر رجعي.
4. التجديد: يمكن لحساب Apple iTunes أن يخصم تلقائياً تكلفة تجديد اشتراكك لمدة تصل إلى 24 ساعة قبل انتهاء صلاحيته. بعد خصم الاشتراك بنجاح، يُمدد الاشتراك لدورة واحدة. الإلغاء: يمكنك إلغاء اشتراكك في أي وقت يصل إلى 48 ساعة قبل انتهاء صلاحيته.
5. إذا كانت لديكم أي أسئلة أو واجهتم أي مشاكل أثناء عملية الطلب، يرجى الاتصال بكم.
"""#
    
    
    let enTitle = "1. After successful purchase,If you haven't checked in today, please visit the check-in page to claim your daily bonus.If you've already checked in, your bonus will be automatically credited to your account. You can check it in the \"Reward Bonus\" section;2. Example:Weekly ,Receive 1,500 coins instantly upon purchase.Get 80 bonus coins for daily check-ins over 7 consecutive days, totaling 2060;Monthly,Receive 2,500 coins instantly upon purchase.Get 120 bonus coins for daily Check-ins over 30 consecutive days, totaling 6,100.The actual rewards granted will prevail;3. If you do not sign in to receive the corresponding bonus on the same day,Rewards cannot be claimed retroactively;4. Renewal: Your Apple iTunes account can automatically deduct the cost of renewing your subscription up to 24 hours before it expires. After successful deduction, the subscription will be extended by one cycle. Cancellation: You may cancel your subscription at any time up to 48 hours prior to its expiration;5. If you have any questions or encounter any issues during the ordering process, please contact."
    
    let entitleDict:[String:String] = ["Reward Bonus":"wwww.baidu.com","Check-ins":"wwww.baidu.com","48 hours":"wwww.baidu.com"]
    
    let hctitleDict:[String:String] = ["奖励奖励":"wwww.baidu.com","取消订阅":"wwww.baidu.com","续订":"wwww.baidu.com"]
    
    let hcTitle = "“1. 成功购买后，如果您今天尚未签到，请访问签到页面来领取每日奖励。如果您已经签到，您的奖励将自动存入您的账户。您可以在“奖励奖励”部分查看；2. 示例：每周，购买时立即获得 1500 个金币。连续 7 天每天签到可获得 80 个奖励金币，总计 2060 个；每月，购买时立即获得 2500 个金币。连续 30 天每天签到可获得 120 个奖励金币，总计 6100 个。实际发放的奖励以实际为准；3. 如果您当天未登录以领取相应的奖励，奖励将无法追溯领取；4. 续订：您的苹果 iTunes 账户可以在订阅到期前 24 小时内自动扣除续订费用。成功扣除后，订阅将延长一个周期。取消：您可以在订阅到期前 48 小时内随时取消订阅；5. 如果在订购过程中有任何疑问或遇到任何问题，请联系。”"
    
    lazy var label: UILabel = {
        let view = UILabel(frame: CGRect(x: 20.adap, y: 100.adap, width: UIScreen.width-40.adap, height: 500.adap))
        view.text = hcTitle
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 15.adap, weight: .bold)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.sizeToFit()
        view.addSubview(label)
        label.changeTextColors([.red,.green,.blue], for: hctitleDict.allKeys())
        label.addGestureTap { tap in
            tap.didTapLabelAttributedText(self.hctitleDict) { key, value in
                print("key===:\(key)====value:\(String(describing: value))")
            }
        }
    }
    
} 
