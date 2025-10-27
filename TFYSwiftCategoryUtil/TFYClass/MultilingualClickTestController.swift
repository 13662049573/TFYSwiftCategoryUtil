//
//  MultilingualClickTestController.swift
//  TFYSwiftCategoryUtil
//
//  Created by TFY on 2024
//
//  MultilingualClickTestController - 多语言富文本点击测试控制器
//
//  功能说明：
//  - 测试支持9种语言的富文本点击检测功能
//  - 验证中文、英文、阿拉伯语、泰语、韩语、日语、俄语、法语、德语的点击检测
//  - 展示不同语言的文本匹配算法和点击响应机制
//  - 提供详细的调试信息和测试结果反馈
//  - 支持RTL（从右到左）语言的正确显示和点击检测
//

import UIKit
import CoreText

/// 多语言富文本点击测试控制器
/// 用于测试和验证TFYSwiftLabel在不同语言环境下的点击检测功能
class MultilingualClickTestController: UIViewController {
    
    // MARK: - 多语言测试数据
    
    /// 支持的语言类型枚举
    private enum SupportedLanguage: String, CaseIterable {
        case chinese = "中文"
        case english = "英文"
        case arabic = "阿拉伯语"
        case thai = "泰语"
        case korean = "韩语"
        case japanese = "日语"
        case russian = "俄语"
        case french = "法语"
        case german = "德语"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    /// 中文测试数据 - 可点击文本字典
    private let chineseDict: [String: String] = [
        "奖励奖励": "https://example.com/chinese/reward",
        "取消订阅": "https://example.com/chinese/cancel",
        "续订": "https://example.com/chinese/renew"
    ]
    
    /// 中文测试文本内容
    private let chineseText = "1. 成功购买后，如果您今天尚未签到，请访问签到页面来领取每日奖励。如果您已经签到，您的奖励将自动存入您的账户。您可以在\"奖励奖励\"部分查看；2. 示例：每周，购买时立即获得 1500 个金币。连续 7 天每天签到可获得 80 个奖励金币，总计 2060 个；每月，购买时立即获得 2500 个金币。连续 30 天每天签到可获得 120 个奖励金币，总计 6100 个。实际发放的奖励以实际为准；3. 如果您当天未登录以领取相应的奖励，奖励将无法追溯领取；4. 续订：您的苹果 iTunes 账户可以在订阅到期前 24 小时内自动扣除续订费用。成功扣除后，订阅将延长一个周期。取消：您可以在订阅到期前 48 小时内随时取消订阅；5. 如果在订购过程中有任何疑问或遇到任何问题，请联系。"
    
    /// 英文测试数据 - 可点击文本字典
    private let englishDict: [String: String] = [
        "Reward Bonus": "https://example.com/english/reward",
        "Check-ins": "https://example.com/english/checkin",
        "48 hours": "https://example.com/english/48hours"
    ]
    
    /// 英文测试文本内容
    private let englishText = "1. After successful purchase,If you haven't checked in today, please visit the check-in page to claim your daily bonus.If you've already checked in, your bonus will be automatically credited to your account. You can check it in the \"Reward Bonus\" section;2. Example:Weekly ,Receive 1,500 coins instantly upon purchase.Get 80 bonus coins for daily check-ins over 7 consecutive days, totaling 2060;Monthly,Receive 2,500 coins instantly upon purchase.Get 120 bonus coins for daily Check-ins over 30 consecutive days, totaling 6,100.The actual rewards granted will prevail;3. If you do not sign in to receive the corresponding bonus on the same day,Rewards cannot be claimed retroactively;4. Renewal: Your Apple iTunes account can automatically deduct the cost of renewing your subscription up to 24 hours before it expires. After successful deduction, the subscription will be extended by one cycle. Cancellation: You may cancel your subscription at any time up to 48 hours prior to its expiration;5. If you have any questions or encounter any issues during the ordering process, please contact."
    
    // 阿拉伯语测试数据
    let arabicDict: [String: String] = [
        "مكافأة مكافأة": "https://example.com/arabic/reward",
        "تسجيل الدخول": "https://example.com/arabic/checkin",
        "48 ساعة قبل انتهاء صلاحيته": "https://example.com/arabic/48hours"
    ]
    
    let arabicText = "1. بعد الشراء الناجح، إذا لم تقم بتسجيل الدخول اليوم، يرجى زيارة صفحة تسجيل الدخول للمطالبة بعلاوتك اليومية. إذا قمت بالدخول بالفعل، سيتم تقييد علاوتك تلقائيًا في حسابك. يمكنك التحقق منه في القسم \"مكافأة مكافأة\". 2. على سبيل المثال: أسبوعياً، تتلقى 1500 قطعة نقدية على الفور عند الشراء. احصل على 80 قطعة نقدية إضافية لعمليات الفحص اليومية على مدى 7 أيام متتالية، بمجموع 2060؛ شهرياً، تتلقى 2500 قطعة نقدية على الفور عند الشراء. احصل على 120 عملة إضافية مقابل عمليات تسجيل الدخول اليومية على مدى 30 يوماً متتالياً، بمجموع 6100 دولار. تسود المكافآت الفعلية الممنوحة. 3. إذا لم تسجل الدخول للحصول على المكافأة المقابلة في نفس اليوم، فلا يمكن المطالبة بالمكافآت بأثر رجعي. 4. التجديد: يمكن لحساب Apple iTunes أن يخصم تلقائياً تكلفة تجديد اشتراكك لمدة تصل إلى 24 ساعة قبل انتهاء صلاحيته. بعد خصم الاشتراك بنجاح، يُمدد الاشتراك لدورة واحدة. الإلغاء: يمكنك إلغاء اشتراكك في أي وقت يصل إلى 48 ساعة قبل انتهاء صلاحيته. 5. إذا كانت لديكم أي أسئلة أو واجهتم أي مشاكل أثناء عملية الطلب، يرجى الاتصال بكم."
    
    // 泰语测试数据
    let thaiDict: [String: String] = [
        "รางวัลโบนัส": "https://example.com/thai/reward",
        "เช็คอินวันนี้": "https://example.com/thai/checkin",
        "48 ชั่วโมงก่อนหมดอายุ": "https://example.com/thai/48hours"
    ]
    
    let thaiText = "1. หลังจากซื้อสำเร็จ หากคุณยังไม่ได้เช็คอินวันนี้ กรุณาไปที่หน้าเช็คอินเพื่อรับโบนัสรายวัน หากคุณเช็คอินแล้ว โบนัสของคุณจะถูกเพิ่มเข้าบัญชีโดยอัตโนมัติ คุณสามารถตรวจสอบได้ในส่วน \"รางวัลโบนัส\" 2. ตัวอย่าง: รายสัปดาห์ รับ 1,500 เหรียญทันทีเมื่อซื้อ รับ 80 เหรียญโบนัสสำหรับการเช็คอินรายวันเป็นเวลา 7 วันติดต่อกัน รวม 2,060; รายเดือน รับ 2,500 เหรียญทันทีเมื่อซื้อ รับ 120 เหรียญโบนัสสำหรับการเช็คอินรายวันเป็นเวลา 30 วันติดต่อกัน รวม 6,100 รางวัลที่ได้รับจริงจะมีผล 3. หากคุณไม่ได้เข้าสู่ระบบเพื่อรับโบนัสที่สอดคล้องกันในวันเดียวกัน รางวัลไม่สามารถรับย้อนหลังได้ 4. การต่ออายุ: บัญชี Apple iTunes ของคุณสามารถหักค่าธรรมเนียมการต่ออายุการสมัครสมาชิกโดยอัตโนมัติได้ถึง 24 ชั่วโมงก่อนหมดอายุ หลังจากหักเงินสำเร็จ การสมัครสมาชิกจะขยายออกไปหนึ่งรอบ การยกเลิก: คุณสามารถยกเลิกการสมัครสมาชิกได้ตลอดเวลาถึง 48 ชั่วโมงก่อนหมดอายุ 5. หากคุณมีคำถามหรือพบปัญหาขณะสั่งซื้อ กรุณาติดต่อ"
    
    // 韩语测试数据
    let koreanDict: [String: String] = [
        "보상 보너스": "https://example.com/korean/reward",
        "체크인하지": "https://example.com/korean/checkin",
        "만료 48시간 전까지": "https://example.com/korean/48hours"
    ]
    
    let koreanText = "1. 구매 성공 후, 오늘 아직 체크인하지 않았다면 일일 보너스를 받기 위해 체크인 페이지를 방문해 주세요. 이미 체크인했다면 보너스가 자동으로 계정에 적립됩니다. \"보상 보너스\" 섹션에서 확인할 수 있습니다. 2. 예시: 주간, 구매 시 즉시 1,500코인을 받습니다. 연속 7일간 매일 체크인하면 80 보너스 코인을 받아 총 2,060개; 월간, 구매 시 즉시 2,500코인을 받습니다. 연속 30일간 매일 체크인하면 120 보너스 코인을 받아 총 6,100개입니다. 실제 지급되는 보상이 우선됩니다. 3. 같은 날 해당 보너스를 받기 위해 로그인하지 않으면 보상을 소급해서 받을 수 없습니다. 4. 갱신: Apple iTunes 계정이 만료 24시간 전까지 구독 갱신 비용을 자동으로 차감할 수 있습니다. 성공적으로 차감된 후 구독이 한 주기 연장됩니다. 취소: 만료 48시간 전까지 언제든지 구독을 취소할 수 있습니다. 5. 주문 과정에서 질문이나 문제가 있으시면 연락해 주세요."
    
    // 日语测试数据
    let japaneseDict: [String: String] = [
        "報酬ボーナス": "https://example.com/japanese/reward",
        "チェックイン": "https://example.com/japanese/checkin",
        "48時間": "https://example.com/japanese/48hours"
    ]
    
    let japaneseText = "1. 購入成功後、今日まだチェックインしていない場合は、毎日のボーナスを受け取るためにチェックインページにアクセスしてください。すでにチェックインしている場合、ボーナスは自動的にアカウントに追加されます。\"報酬ボーナス\"セクションで確認できます。2. 例：週間、購入時に即座に1,500コインを受け取ります。連続7日間毎日チェックインすると80ボーナスコインを受け取り、合計2,060個；月間、購入時に即座に2,500コインを受け取ります。連続30日間毎日チェックインすると120ボーナスコインを受け取り、合計6,100個です。実際に付与される報酬が優先されます。3. 同じ日に該当するボーナスを受け取るためにログインしない場合、報酬は遡って受け取ることはできません。4. 更新：Apple iTunesアカウントは期限切れの24時間前までサブスクリプション更新料金を自動的に差し引くことができます。成功した差し引き後、サブスクリプションは1サイクル延長されます。キャンセル：期限切れの48時間前までいつでもサブスクリプションをキャンセルできます。5. 注文プロセス中にご質問や問題がございましたら、お問い合わせください。"
    
    // 俄语测试数据
    let russianDict: [String: String] = [
        "Бонус награды": "https://example.com/russian/reward",
        "зарегистрировались": "https://example.com/russian/checkin",
        "48 часов до истечения срока": "https://example.com/russian/48hours"
    ]
    
    let russianText = "1. После успешной покупки, если вы еще не зарегистрировались сегодня, пожалуйста, посетите страницу регистрации, чтобы получить ежедневный бонус. Если вы уже зарегистрировались, ваш бонус будет автоматически зачислен на ваш счет. Вы можете проверить это в разделе \"Бонус награды\". 2. Пример: Еженедельно, получите 1500 монет мгновенно при покупке. Получите 80 бонусных монет за ежедневную регистрацию в течение 7 дней подряд, всего 2060; Ежемесячно, получите 2500 монет мгновенно при покупке. Получите 120 бонусных монет за ежедневную регистрацию в течение 30 дней подряд, всего 6100. Действуют фактические награды. 3. Если вы не войдете в систему, чтобы получить соответствующий бонус в тот же день, награды не могут быть получены задним числом. 4. Продление: Ваш аккаунт Apple iTunes может автоматически списать стоимость продления подписки за 24 часа до истечения срока. После успешного списания подписка будет продлена на один цикл. Отмена: Вы можете отменить подписку в любое время до 48 часов до истечения срока. 5. Если у вас есть вопросы или возникли проблемы в процессе заказа, пожалуйста, свяжитесь с нами."
    
    // 法语测试数据
    let frenchDict: [String: String] = [
        "Bonus de récompense": "https://example.com/french/reward",
        "Enregistrement": "https://example.com/french/checkin",
        "48 heures": "https://example.com/french/48hours"
    ]
    
    let frenchText = "1. Après un achat réussi, si vous ne vous êtes pas encore enregistré aujourd'hui, veuillez visiter la page d'enregistrement pour réclamer votre bonus quotidien. Si vous vous êtes déjà enregistré, votre bonus sera automatiquement crédité sur votre compte. Vous pouvez le vérifier dans la section \"Bonus de récompense\". 2. Exemple: Hebdomadaire, recevez 1500 pièces instantanément lors de l'achat. Obtenez 80 pièces bonus pour les enregistrements quotidiens sur 7 jours consécutifs, totalisant 2060; Mensuel, recevez 2500 pièces instantanément lors de l'achat. Obtenez 120 pièces bonus pour les enregistrements quotidiens sur 30 jours consécutifs, totalisant 6100. Les récompenses réelles accordées prévalent. 3. Si vous ne vous connectez pas pour recevoir le bonus correspondant le même jour, les récompenses ne peuvent pas être réclamées rétroactivement. 4. Renouvellement: Votre compte Apple iTunes peut automatiquement déduire le coût du renouvellement de votre abonnement jusqu'à 24 heures avant son expiration. Après déduction réussie, l'abonnement sera étendu d'un cycle. Annulation: Vous pouvez annuler votre abonnement à tout moment jusqu'à 48 heures avant son expiration. 5. Si vous avez des questions ou rencontrez des problèmes pendant le processus de commande, veuillez nous contacter."
    
    // 德语测试数据
    let germanDict: [String: String] = [
        "Belohnungsbonus": "https://example.com/german/reward",
        "Einchecken": "https://example.com/german/checkin",
        "48 Stunden": "https://example.com/german/48hours"
    ]
    
    let germanText = "1. Nach erfolgreichem Kauf, wenn Sie sich heute noch nicht eingecheckt haben, besuchen Sie bitte die Eincheckseite, um Ihren täglichen Bonus zu erhalten. Wenn Sie sich bereits eingecheckt haben, wird Ihr Bonus automatisch auf Ihr Konto gutgeschrieben. Sie können es im Abschnitt \"Belohnungsbonus\" überprüfen. 2. Beispiel: Wöchentlich, erhalten Sie 1500 Münzen sofort beim Kauf. Erhalten Sie 80 Bonusmünzen für tägliches Einchecken über 7 aufeinanderfolgende Tage, insgesamt 2060; Monatlich, erhalten Sie 2500 Münzen sofort beim Kauf. Erhalten Sie 120 Bonusmünzen für tägliches Einchecken über 30 aufeinanderfolgende Tage, insgesamt 6100. Die tatsächlich gewährten Belohnungen haben Vorrang. 3. Wenn Sie sich nicht anmelden, um den entsprechenden Bonus am selben Tag zu erhalten, können Belohnungen nicht rückwirkend beansprucht werden. 4. Verlängerung: Ihr Apple iTunes-Konto kann die Kosten für die Verlängerung Ihres Abonnements automatisch bis zu 24 Stunden vor Ablauf abziehen. Nach erfolgreichem Abzug wird das Abonnement um einen Zyklus verlängert. Stornierung: Sie können Ihr Abonnement jederzeit bis zu 48 Stunden vor Ablauf stornieren. 5. Wenn Sie Fragen haben oder Probleme beim Bestellvorgang haben, kontaktieren Sie uns bitte."
    
    // MARK: - UI 组件
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var chineseLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: chineseText)
        return label
    }()
    
    lazy var englishLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: englishText)
        return label
    }()
    
    lazy var arabicLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: arabicText)
        return label
    }()
    
    lazy var thaiLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: thaiText)
        return label
    }()
    
    lazy var koreanLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: koreanText)
        return label
    }()
    
    lazy var japaneseLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: japaneseText)
        return label
    }()
    
    lazy var russianLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: russianText)
        return label
    }()
    
    lazy var frenchLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: frenchText)
        return label
    }()
    
    lazy var germanLabel: TFYSwiftLabel = {
        let label = createStyledLabel(text: germanText)
        return label
    }()
    
    /// 创建样式化的标签
    /// - Parameter text: 标签文本
    /// - Returns: 配置好的TFYSwiftLabel
    private func createStyledLabel(text: String) -> TFYSwiftLabel {
        let label = TFYSwiftLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.backgroundColor = UIColor.systemBackground
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemGray4.cgColor
        label.textAlignment = .left
        
        // 设置内边距
        label.layer.masksToBounds = true
        
        return label
    }
    
    
    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🎯 点击测试结果将显示在这里\n🌍 支持的语言：中文、英文、阿拉伯语、泰语、韩语、日语、俄语、法语、德语\n💡 请选择语言后点击文本中的可点击部分进行测试"
        label.numberOfLines = 0
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        
        return label
    }()
    
    lazy var controlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var languageSegmentedControl: UISegmentedControl = {
        let items = SupportedLanguage.allCases.map { $0.displayName }
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(languageChanged(_:)), for: .valueChanged)
        control.backgroundColor = UIColor.systemGray6
        control.selectedSegmentTintColor = UIColor.systemBlue
        return control
    }()
    
    lazy var currentLanguageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "当前语言: 中文"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMultilingualClickTests()
        initializeUIState()
    }
    
    /// 初始化UI状态
    private func initializeUIState() {
        // 隐藏所有标签
        hideAllLabels()
        
        // 默认显示中文测试
        chineseLabel.isHidden = false
        
        // 设置初始提示文本
        resultLabel.text = "✅ 已切换到 中文 测试\n🎯 请点击文本中的可点击部分进行测试\n💡 可点击的文本会以不同颜色显示"
    }
    
    // MARK: - UI 设置
    
    /// 设置用户界面
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置导航栏
        setupNavigationBar()
        
        // 添加子视图
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 设置控制面板
        setupControlPanel()
        
        // 设置内容区域
        setupContentArea()
        
        // 设置约束
        setupConstraints()
    }
    
    /// 设置导航栏
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    /// 设置控制面板
    private func setupControlPanel() {
        // 添加控制面板到内容视图
        contentView.addSubview(controlStackView)
        
        // 添加控件到控制面板
        controlStackView.addArrangedSubview(currentLanguageLabel)
        controlStackView.addArrangedSubview(languageSegmentedControl)
        
        // 设置控制面板样式
        controlStackView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        controlStackView.layer.cornerRadius = 12
        controlStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        controlStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    /// 设置内容区域
    private func setupContentArea() {
        // 添加内容堆栈视图
        contentView.addSubview(contentStackView)
        
        // 添加所有语言标签到内容区域
        let allLabels = [chineseLabel, englishLabel, arabicLabel, thaiLabel, koreanLabel, japaneseLabel, russianLabel, frenchLabel, germanLabel]
        for label in allLabels {
            contentStackView.addArrangedSubview(label)
        }
        
        // 添加结果标签
        contentStackView.addArrangedSubview(resultLabel)
    }
    
    /// 设置约束
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView 约束
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView 约束
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 控制面板约束
            controlStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            controlStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controlStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 内容区域约束
            contentStackView.topAnchor.constraint(equalTo: controlStackView.bottomAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 多语言点击测试设置
    
    /// 设置多语言点击测试
    private func setupMultilingualClickTests() {
        // 设置中文点击测试
        setupClickTest(for: chineseLabel, with: chineseDict, language: "中文")
        
        // 设置英文点击测试
        setupClickTest(for: englishLabel, with: englishDict, language: "英文")
        
        // 设置阿拉伯语点击测试
        setupClickTest(for: arabicLabel, with: arabicDict, language: "阿拉伯语")
        
        // 设置泰语点击测试
        setupClickTest(for: thaiLabel, with: thaiDict, language: "泰语")
        
        // 设置韩语点击测试
        setupClickTest(for: koreanLabel, with: koreanDict, language: "韩语")
        
        // 设置日语点击测试
        setupClickTest(for: japaneseLabel, with: japaneseDict, language: "日语")
        
        // 设置俄语点击测试
        setupClickTest(for: russianLabel, with: russianDict, language: "俄语")
        
        // 设置法语点击测试
        setupClickTest(for: frenchLabel, with: frenchDict, language: "法语")
        
        // 设置德语点击测试
        setupClickTest(for: germanLabel, with: germanDict, language: "德语")
    }
    
    /// 设置点击测试
    /// - Parameters:
    ///   - label: 要设置的标签
    ///   - dict: 可点击文本字典
    ///   - language: 语言名称
    private func setupClickTest(for label: TFYSwiftLabel, with dict: [String: String], language: String) {
        label
            .clickableTexts(dict,textColors: [.red,.green,.blue]) { [weak self] key, value in
                self?.handleClickResult(language: language, key: key, value: value)
            }
            .clickHighlight(color: .systemBlue.withAlphaComponent(0.3), duration: 0.2)
            .debugMode()
    }
    
    
    // MARK: - 点击结果处理
    
    /// 处理点击结果
    /// - Parameters:
    ///   - language: 语言名称
    ///   - key: 点击的文本
    ///   - value: 对应的链接
    private func handleClickResult(language: String, key: String, value: String?) {
        let result = "\(language) - 点击了: \(key)\n链接: \(value ?? "无")"
        print("✅ 点击检测成功 - \(result)")
        // 更新结果标签
        DispatchQueue.main.async { [weak self] in
            self?.resultLabel.text = result
        }
        // 显示成功提示
        showClickSuccessAlert(language: language, clickedText: key, link: value)
    }
    
    /// 显示点击成功提示
    /// - Parameters:
    ///   - language: 语言名称
    ///   - clickedText: 点击的文本
    ///   - link: 对应的链接
    private func showClickSuccessAlert(language: String, clickedText: String, link: String?) {
        let alert = UIAlertController(
            title: "🎉 点击检测成功",
            message: "语言: \(language)\n点击文本: \(clickedText)\n链接: \(link ?? "无")",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        
        // 如果有链接，添加打开链接的选项
        if let link = link, !link.isEmpty {
            alert.addAction(UIAlertAction(title: "打开链接", style: .default) { _ in
                if let url = URL(string: link) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        }
        
        present(alert, animated: true)
    }
    
    
    // MARK: - 语言和测试模式切换
    
    /// 语言切换处理方法
    /// - Parameter sender: 分段控制器
    @objc private func languageChanged(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex < SupportedLanguage.allCases.count else { return }
        
        let selectedLanguage = SupportedLanguage.allCases[sender.selectedSegmentIndex]
        
        // 更新当前语言标签
        currentLanguageLabel.text = "当前语言: \(selectedLanguage.displayName)"
        
        // 隐藏所有标签
        hideAllLabels()
        
        // 显示选中的语言标签
        showLanguageLabel(for: selectedLanguage)
        
        // 更新结果提示
        resultLabel.text = "✅ 已切换到 \(selectedLanguage.displayName) 测试\n🎯 请点击文本中的可点击部分进行测试\n💡 可点击的文本会以不同颜色显示"
    }
    
    /// 显示指定语言的标签
    /// - Parameter language: 语言类型
    private func showLanguageLabel(for language: SupportedLanguage) {
        switch language {
        case .chinese:
            chineseLabel.isHidden = false
        case .english:
            englishLabel.isHidden = false
        case .arabic:
            arabicLabel.isHidden = false
        case .thai:
            thaiLabel.isHidden = false
        case .korean:
            koreanLabel.isHidden = false
        case .japanese:
            japaneseLabel.isHidden = false
        case .russian:
            russianLabel.isHidden = false
        case .french:
            frenchLabel.isHidden = false
        case .german:
            germanLabel.isHidden = false
        }
    }
    
    
    /// 隐藏所有语言标签
    private func hideAllLabels() {
        chineseLabel.isHidden = true
        englishLabel.isHidden = true
        arabicLabel.isHidden = true
        thaiLabel.isHidden = true
        koreanLabel.isHidden = true
        japaneseLabel.isHidden = true
        russianLabel.isHidden = true
        frenchLabel.isHidden = true
        germanLabel.isHidden = true
    }
    
    deinit {
        print("🗑️ MultilingualClickTestController 已释放")
    }
    
}
