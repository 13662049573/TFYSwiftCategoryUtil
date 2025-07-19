//
//  JSONAdaptiveDemoController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/12/12.
//  用途：JSON数据驱动的自适应UICollectionView演示，综合使用TFYSwiftCategoryUtil库的所有功能
//  包含：JSON解析、UI链式编程、手势识别、弹窗系统、定时器、异步处理、图片处理、日志系统等
//

import UIKit
import Foundation
import WebKit

// MARK: - 数据模型（基于真实JSON结构）
struct VIPProductResponse: Codable {
    let requestId: String
    let extra: [String: String]
    let traceId: String
    let msg: String
    let statusCode: Int
    let data: VIPProductData
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case extra, traceId = "trace_id", msg, statusCode = "status_code", data
    }
}

struct VIPProductData: Codable {
    let templateId: String
    let autoUnlock: Int
    let vipEndTime: Int
    let surplusCoin: Int
    let subscriptionId: String
    let channelId: String
    let discountInfo: DiscountInfo
    let cycleList: [VIPCycleProduct]
    let coinList: [VIPCoinProduct]
    let isExperiment: Int
    let surplusBonus: Int
    
    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case autoUnlock = "auto_unlock"
        case vipEndTime = "vip_end_time"
        case surplusCoin = "surplus_coin"
        case subscriptionId = "subscription_id"
        case channelId = "channel_id"
        case discountInfo = "discount_info"
        case cycleList = "cycle_list"
        case coinList = "coin_list"
        case isExperiment = "is_experiment"
        case surplusBonus = "surplus_bonus"
    }
}

struct DiscountInfo: Codable {
    let surplusSecond: Int
    let originSubscriptionGroup: String
    let rechargeType: Int
    let productType: Int
    let amount: String
    let productId: String
    let coin: Int
    let subscriptionGroup: String
    let originProductId: String
    let freeCoin: Int
    let discountType: Int
    let isDiscount: Int
    let originAmount: String
    
    enum CodingKeys: String, CodingKey {
        case surplusSecond = "surplus_second"
        case originSubscriptionGroup = "origin_subscription_group"
        case rechargeType = "recharge_type"
        case productType = "product_type"
        case amount, productId = "product_id", coin, subscriptionGroup = "subscription_group"
        case originProductId = "origin_product_id", freeCoin = "free_coin"
        case discountType = "discount_type", isDiscount = "is_discount"
        case originAmount = "origin_amount"
    }
}

struct VIPCycleProduct: Codable {
    let pPriceId: String
    let isRecommend: Int
    let productName: String
    let rechargeType: Int
    let productType: Int
    let offer: VIPOffer?
    let amount: String
    let productId: String
    let priceId: String
    let sort: Int
    let type: String
    let originProduct: OriginProduct?
    let offerCooldown: String
    let offerCountdown: String
    let coin: Int
    let productGroup: String
    let freeCoin: Int
    let offerType: Int
    let signDays: Int
    let signCoin: Int
    let id: String
    let productSubscript: String
    
    enum CodingKeys: String, CodingKey {
        case pPriceId = "p_price_id", isRecommend = "is_recommend", productName = "product_name"
        case rechargeType = "recharge_type", productType = "product_type", offer, amount
        case productId = "product_id", priceId = "price_id", sort, type
        case originProduct = "origin_product", offerCooldown = "offer_cooldown"
        case offerCountdown = "offer_countdown", coin, productGroup = "product_group"
        case freeCoin = "free_coin", offerType = "offer_type", signDays = "sign_days"
        case signCoin = "sign_coin", id, productSubscript = "subscript"
    }
    
    // 计算属性
    var isRecommended: Bool { isRecommend == 1 }
    var price: Double { Double(amount) ?? 0.0 }
    var originalPrice: Double? {
        guard let originProduct = originProduct else { return nil }
        return Double(originProduct.amount)
    }
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    var hasOffer: Bool { offer != nil }
    var offerAmount: String? { offer?.offerAmount }
    var offerCountdownSeconds: Int { Int(offerCountdown) ?? 0 }
}

struct VIPCoinProduct: Codable {
    let pPriceId: String
    let isRecommend: Int
    let productName: String
    let rechargeType: Int
    let productType: Int
    let offer: VIPOffer?
    let amount: String
    let productId: String
    let priceId: String
    let sort: Int
    let type: String
    let originProduct: OriginProduct?
    let offerCooldown: String
    let offerCountdown: String
    let coin: Int
    let productGroup: String
    let freeCoin: Int
    let offerType: Int
    let signDays: Int
    let signCoin: Int
    let id: String
    let productSubscript: String
    
    enum CodingKeys: String, CodingKey {
        case pPriceId = "p_price_id", isRecommend = "is_recommend", productName = "product_name"
        case rechargeType = "recharge_type", productType = "product_type", offer, amount
        case productId = "product_id", priceId = "price_id", sort, type
        case originProduct = "origin_product", offerCooldown = "offer_cooldown"
        case offerCountdown = "offer_countdown", coin, productGroup = "product_group"
        case freeCoin = "free_coin", offerType = "offer_type", signDays = "sign_days"
        case signCoin = "sign_coin", id, productSubscript = "subscript"
    }
    
    // 计算属性
    var isRecommended: Bool { isRecommend == 1 }
    var price: Double { Double(amount) ?? 0.0 }
    var originalPrice: Double? {
        guard let originProduct = originProduct else { return nil }
        return Double(originProduct.amount)
    }
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    var hasOffer: Bool { offer != nil }
    var offerAmount: String? { offer?.offerAmount }
    var totalCoins: Int { coin + freeCoin }
    var bonusText: String { freeCoin > 0 ? "送\(freeCoin)金币" : "" }
}

struct VIPOffer: Codable {
    let offerId: String
    let offerCode: String
    let isOffer: Int
    let offerType: Int
    let offerAmount: String
    let offerCycle: Int
    let offerCountdown: Int
    
    enum CodingKeys: String, CodingKey {
        case offerId = "offer_id", offerCode = "offer_code", isOffer = "is_offer"
        case offerType = "offer_type", offerAmount = "offer_amount"
        case offerCycle = "offer_cycle", offerCountdown = "offer_countdown"
    }
}

struct OriginProduct: Codable {
    let productId: String
    let name: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id", name, amount
    }
}

// MARK: - 扩展功能
extension VIPProductData {
    var allProducts: [Any] {
        return cycleList + coinList
    }
    
    var hasActiveOffers: Bool {
        return cycleList.contains { $0.hasOffer } || coinList.contains { $0.hasOffer }
    }
    
    var totalProducts: Int {
        return cycleList.count + coinList.count
    }
    
    var recommendedProducts: [Any] {
        return allProducts.filter { product in
            if let cycle = product as? VIPCycleProduct {
                return cycle.isRecommended
            } else if let coin = product as? VIPCoinProduct {
                return coin.isRecommended
            }
            return false
        }
    }
    
    /// 转换为字典
    func toDictionary() -> Result<[String: Any], Error> {
        do {
            let data = try JSONEncoder().encode(self)
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return .success(dict)
            } else {
                return .failure(TFYJsonError.invalidData)
            }
        } catch {
            return .failure(error)
        }
    }
    
    /// 转换为JSON字符串
    func toJsonString() -> Result<String, Error> {
        do {
            let data = try JSONEncoder().encode(self)
            if let jsonString = String(data: data, encoding: .utf8) {
                return .success(jsonString)
            } else {
                return .failure(TFYJsonError.invalidData)
            }
        } catch {
            return .failure(error)
        }
    }
    
    /// 从字典创建模型
    static func from(dict: [String: Any]) -> Result<VIPProductData, Error> {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            let model = try JSONDecoder().decode(VIPProductData.self, from: data)
            return .success(model)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - 自适应Cell
class VIPProductCell: UICollectionViewCell {
    
    // MARK: - 手势识别器
    private var tapGesture: UITapGestureRecognizer!
    private var longPressGesture: UILongPressGestureRecognizer!
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()
    private let originalPriceLabel = UILabel()
    private let actionButton = UIButton()
    private let recommendBadge = UIView()
    private let recommendLabel = UILabel()
    private let offerBadge = UIView()
    private let offerLabel = UILabel()
    private let discountBadge = UIView()
    private let discountLabel = UILabel()
    
    // MARK: - Properties
    private var product: Any?
    private var isAnimating = false
    private var originalTransform: CGAffineTransform = .identity
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 使用TFYSwiftCategoryUtil的颜色和样式
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    
        // 容器视图
        containerView
            .tfy
            .backgroundColor(.systemBackground)
            .cornerRadius(12)
            .shadowColor(.black.withAlphaComponent(0.1))
            .shadowOffset(CGSize(width: 0, height: 2))
            .shadowOpacity(0.1)
            .shadowRadius(8)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 图标
        iconImageView
            .tfy
            .contentMode(.scaleAspectFit)
            .cornerRadius(8)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 标题
        titleLabel
            .tfy
            .font(.systemFont(ofSize: 16, weight: .semibold))
            .textColor(.label)
            .numberOfLines(2)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 副标题
        subtitleLabel
            .tfy
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .numberOfLines(2)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 价格
        priceLabel
            .tfy
            .font(.systemFont(ofSize: 18, weight: .bold))
            .textColor(.systemRed)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 原价
        originalPriceLabel
            .tfy
            .font(.systemFont(ofSize: 14))
            .textColor(.tertiaryLabel)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 操作按钮
        actionButton
            .tfy
            .backgroundColor(.systemBlue)
            .cornerRadius(16)
            .titleColor(.white, for: .normal)
            .font(.systemFont(ofSize: 14, weight: .medium))
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 推荐标签
        recommendBadge
            .tfy
            .backgroundColor(.systemOrange)
            .cornerRadius(10)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        recommendLabel
            .tfy
            .text("推荐")
            .font(.systemFont(ofSize: 10, weight: .medium))
            .textColor(.white)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 优惠标签
        offerBadge
            .tfy
            .backgroundColor(.systemGreen)
            .cornerRadius(10)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        offerLabel
            .tfy
            .font(.systemFont(ofSize: 10, weight: .medium))
            .textColor(.white)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 折扣标签
        discountBadge
            .tfy
            .backgroundColor(.systemRed)
            .cornerRadius(10)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        discountLabel
            .tfy
            .font(.systemFont(ofSize: 10, weight: .bold))
            .textColor(.white)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
        
        // 添加子视图
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(originalPriceLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(recommendBadge)
        recommendBadge.addSubview(recommendLabel)
        containerView.addSubview(offerBadge)
        offerBadge.addSubview(offerLabel)
        containerView.addSubview(discountBadge)
        discountBadge.addSubview(discountLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 容器视图
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // 图标
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // 推荐标签
            recommendBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            recommendBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            recommendBadge.widthAnchor.constraint(equalToConstant: 40),
            recommendBadge.heightAnchor.constraint(equalToConstant: 20),
            
            recommendLabel.topAnchor.constraint(equalTo: recommendBadge.topAnchor),
            recommendLabel.leadingAnchor.constraint(equalTo: recommendBadge.leadingAnchor),
            recommendLabel.trailingAnchor.constraint(equalTo: recommendBadge.trailingAnchor),
            recommendLabel.bottomAnchor.constraint(equalTo: recommendBadge.bottomAnchor),
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: recommendBadge.leadingAnchor, constant: -8),
            
            // 副标题
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 优惠标签
            offerBadge.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            offerBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            offerBadge.heightAnchor.constraint(equalToConstant: 20),
            
            offerLabel.topAnchor.constraint(equalTo: offerBadge.topAnchor),
            offerLabel.leadingAnchor.constraint(equalTo: offerBadge.leadingAnchor, constant: 6),
            offerLabel.trailingAnchor.constraint(equalTo: offerBadge.trailingAnchor, constant: -6),
            offerLabel.bottomAnchor.constraint(equalTo: offerBadge.bottomAnchor),
            
            // 折扣标签
            discountBadge.topAnchor.constraint(equalTo: offerBadge.bottomAnchor, constant: 4),
            discountBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            discountBadge.widthAnchor.constraint(equalToConstant: 50),
            discountBadge.heightAnchor.constraint(equalToConstant: 20),
            
            discountLabel.topAnchor.constraint(equalTo: discountBadge.topAnchor),
            discountLabel.leadingAnchor.constraint(equalTo: discountBadge.leadingAnchor),
            discountLabel.trailingAnchor.constraint(equalTo: discountBadge.trailingAnchor),
            discountLabel.bottomAnchor.constraint(equalTo: discountBadge.bottomAnchor),
            
            // 价格
            priceLabel.topAnchor.constraint(equalTo: discountBadge.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // 原价
            originalPriceLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            originalPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),
            
            // 操作按钮
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            actionButton.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            actionButton.heightAnchor.constraint(equalToConstant: 32),
            
            // 关键：确保价格标签和按钮之间有正确的垂直关系
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -8),
            originalPriceLabel.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -8)
        ])
        
        // 确保容器视图有明确的高度约束
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        // 确保contentView有明确的约束，这对自适应布局很重要
        contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        
        // 添加最大宽度约束，防止无限扩展
        contentView.widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
    }

    // MARK: - 弹窗系统
    private func showProductDetailPopup() {
        guard product != nil else { return }
        
        // 创建弹窗内容视图
        let popupView = createProductDetailView()
        
        // 使用TFYSwiftCategoryUtil的弹窗系统
        let popup = TFYSwiftPopupView(
            containerView: UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }!,
            contentView: popupView,
            configuration: createPopupConfiguration()
        )
        
        popup.show()
    }
    
    private func createProductDetailView() -> UIView {
        let containerView = UIView()
            .tfy
            .backgroundColor(.systemBackground)
            .cornerRadius(16)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        let titleLabel = UILabel()
            .tfy
            .text("产品详情")
            .font(.systemFont(ofSize: 18, weight: .bold))
            .textColor(.label)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        let detailLabel = UILabel()
            .tfy
            .text({
                if let cycle = product as? VIPCycleProduct {
                    return cycle.productName + "\n" + cycle.productSubscript
                } else if let coin = product as? VIPCoinProduct {
                    return coin.productName + "\n" + coin.productSubscript
                } else {
                    return ""
                }
            }())
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .numberOfLines(0)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        let closeButton = UIButton()
            .tfy
            .title("关闭", for: .normal)
            .titleColor(.systemBlue, for: .normal)
            .backgroundColor(.systemGray6)
            .cornerRadius(8)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        containerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return containerView
    }
    
    private func createPopupConfiguration() -> TFYSwiftPopupViewConfiguration {
        var config = TFYSwiftPopupViewConfiguration()
        config.isDismissible = true
        config.isInteractive = true
        config.animationDuration = 0.3
        config.cornerRadius = 16
        config.shadowConfiguration.isEnabled = true
        config.shadowConfiguration.color = .black
        config.shadowConfiguration.opacity = 0.3
        config.shadowConfiguration.radius = 10
        return config
    }
    
    @objc private func closePopup() {
        // 关闭弹窗的逻辑
        TFYUtils.Logger.log("关闭产品详情弹窗", level: .info)
    }
    
    // MARK: - 自适应布局
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        
        // 获取CollectionView的宽度作为参考
        let targetWidth = layoutAttributes.frame.width
        
        // 设置contentView的宽度约束
        contentView.widthAnchor.constraint(equalToConstant: targetWidth).isActive = true
        
        // 计算自适应高度
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        // 确保尺寸有效
        let validSize = CGSize(
            width: max(100, min(targetWidth, size.width)),
            height: max(80, min(1000, size.height))
        )
        
        var newFrame = layoutAttributes.frame
        newFrame.size = validSize
        layoutAttributes.frame = newFrame
        
        // 移除临时约束
        contentView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width && constraint.firstItem === contentView {
                contentView.removeConstraint(constraint)
            }
        }
        
        return layoutAttributes
    }
    
    // MARK: - 配置Cell
    func configure(with product: Any) {
        self.product = product
        
        // 确保约束正确设置
        setNeedsLayout()
        layoutIfNeeded()
        
        if let cycleProduct = product as? VIPCycleProduct {
            configureCycleProduct(cycleProduct)
        } else if let coinProduct = product as? VIPCoinProduct {
            configureCoinProduct(coinProduct)
        }
        
        // 配置完成后重新布局
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func configureCycleProduct(_ product: VIPCycleProduct) {
        // 使用TFYSwiftCategoryUtil的字符串处理
        titleLabel.text = product.productName
        subtitleLabel.text = product.productSubscript
        
        // 价格格式化
        let priceText = "$\(product.amount)"
        priceLabel.text = priceText
        
        if let originalPrice = product.originalPrice {
            let originalText = "$\(String(format: "%.2f", originalPrice))"
            originalPriceLabel.text = originalText
            originalPriceLabel.isHidden = false
            
            // 添加删除线
            let attributedString = NSAttributedString(
                string: originalText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = attributedString
        } else {
            originalPriceLabel.isHidden = true
        }
        
        // 操作按钮
        actionButton.setTitle("订阅", for: .normal)
        
        // 推荐标签
        recommendBadge.isHidden = !product.isRecommended
        
        // 优惠标签
        if product.hasOffer {
            offerLabel.text = "限时"
            offerBadge.isHidden = false
        } else {
            offerBadge.isHidden = true
        }
        
        // 折扣标签
        if let discount = product.discountPercentage {
            discountLabel.text = "-\(discount)%"
            discountBadge.isHidden = false
        } else {
            discountBadge.isHidden = true
        }
        
        // 图标（使用TFYSwiftCategoryUtil的图片处理）
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: "crown.fill", withConfiguration: config)?
            .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
    }
    
    private func configureCoinProduct(_ product: VIPCoinProduct) {
        titleLabel.text = product.productName
        subtitleLabel.text = "\(product.coin) 金币 + \(product.freeCoin) 赠送 (\(product.productSubscript))"
        
        // 价格格式化
        let priceText = "$\(product.amount)"
        priceLabel.text = priceText
        
        if let originalPrice = product.originalPrice {
            let originalText = "$\(String(format: "%.2f", originalPrice))"
            originalPriceLabel.text = originalText
            originalPriceLabel.isHidden = false
            
            // 添加删除线
            let attributedString = NSAttributedString(
                string: originalText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            originalPriceLabel.attributedText = attributedString
        } else {
            originalPriceLabel.isHidden = true
        }
        
        // 操作按钮
        actionButton.setTitle("充值", for: .normal)
        
        // 推荐标签
        recommendBadge.isHidden = !product.isRecommended
        
        // 优惠标签
        if product.hasOffer {
            offerLabel.text = "优惠"
            offerBadge.isHidden = false
        } else {
            offerBadge.isHidden = true
        }
        
        // 折扣标签
        if let discount = product.discountPercentage {
            discountLabel.text = "-\(discount)%"
            discountBadge.isHidden = false
        } else {
            discountBadge.isHidden = true
        }
        
        // 图标
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: "dollarsign.circle.fill", withConfiguration: config)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        product = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        priceLabel.text = nil
        originalPriceLabel.text = nil
        actionButton.setTitle(nil, for: .normal)
        iconImageView.image = nil
        recommendBadge.isHidden = true
        offerBadge.isHidden = true
        discountBadge.isHidden = true
        
        // 重置动画状态
        isAnimating = false
        transform = .identity
        
        // 重置约束状态
        contentView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width && constraint.firstItem === contentView {
                contentView.removeConstraint(constraint)
            }
        }
        
        // 确保约束正确
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - 主控制器
class JSONAdaptiveDemoController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var vipResponse: VIPProductResponse?
    private var vipData: VIPProductData?
    private var allProducts: [Any] = []
    private var currentLayoutType: String = "完全自适应"
    private var refreshControl: UIRefreshControl!
    
    // MARK: - TFYSwiftCategoryUtil工具
    private var autoRefreshTimer: TFYTimer?
    private var webView: WKWebView?
    private var imageStitcher: TFYStitchImage?
    private var asyncTask: DispatchWorkItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupTFYSwiftTools()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAutoRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 使用TFYSwiftCategoryUtil的UIViewController扩展
        title = "JSON自适应布局 (\(currentLayoutType))"
        view.backgroundColor = .systemGroupedBackground
        
        // 使用TFYSwiftCategoryUtil的导航栏设置
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "刷新",
                style: .plain,
                target: self,
                action: #selector(refreshData)
            ),
            UIBarButtonItem(
                title: "布局",
                style: .plain,
                target: self,
                action: #selector(changeLayout)
            )
        ]
        
        // 使用TFYSwiftCategoryUtil的日志系统
        TFYUtils.Logger.log("JSONAdaptiveDemoController 初始化完成", level: .info)
    }
    
    // MARK: - TFYSwift工具设置
    private func setupTFYSwiftTools() {
        // 初始化图片拼接工具
        imageStitcher = TFYStitchImage()
        
        // 初始化WebView（用于显示产品详情）
        setupWebView()
        
        // 使用TFYSwiftCategoryUtil的异步处理工具
        TFYAsynce.async(qos: .userInitiated) {
            TFYUtils.Logger.log("后台任务开始执行", level: .info)
            // 模拟后台数据处理
            Thread.sleep(forTimeInterval: 1.0)
        } mainBlock: {
            TFYUtils.Logger.log("后台任务完成，UI已更新", level: .info)
        }
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.isHidden = true
        view.addSubview(webView!)
        
        // 使用TFYSwiftCategoryUtil的WebView管理
        if let webView = webView {
            webView.tfy
                .translatesAutoresizingMaskIntoConstraints(false)
                .isHidden(true)
        }
    }
    
    // MARK: - 自动刷新功能
    private func startAutoRefresh() {
        // 使用TFYSwiftCategoryUtil的定时器
        autoRefreshTimer = TFYTimer.repeaticTimer(
            interval: .seconds(30),
            handler: { [weak self] _ in
                TFYUtils.Logger.log("自动刷新定时器触发", level: .info)
                self?.performAutoRefresh()
            }
        )
        autoRefreshTimer?.start()
    }
    
    private func stopAutoRefresh() {
        autoRefreshTimer?.suspend()
        autoRefreshTimer = nil
    }
    
    private func performAutoRefresh() {
        // 使用TFYSwiftCategoryUtil的异步处理
        TFYAsynce.async(qos: .background) {
            // 模拟网络请求
            Thread.sleep(forTimeInterval: 0.5)
        } mainBlock: { [weak self] in
            self?.collectionView.reloadData()
            TFYUtils.Logger.log("自动刷新完成", level: .info)
        }
    }
    
    private func setupCollectionView() {
        // 创建FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // 设置预估尺寸，这对自适应布局很重要
        layout.estimatedItemSize = CGSize(width: 300, height: 120)
        
        // 创建CollectionView
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView
            .tfy
            .backgroundColor(.systemGroupedBackground)
            .delegate(self)
            .dataSource(self)
            .registerCell(VIPProductCell.self)
            .translatesAutoresizingMaskIntoConstraints(false)
            .showsVerticalScrollIndicator(false)
        
        // 添加刷新控件
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 验证布局配置
        validateLayoutConfiguration()
    }
    
    private func validateLayoutConfiguration() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            TFYUtils.Logger.log("布局验证失败：不是FlowLayout", level: .warning)
            return
        }
        
        // 检查是否使用自适应布局
        if flowLayout.estimatedItemSize.width > 0 && flowLayout.estimatedItemSize.height > 0 {
            TFYUtils.Logger.log("布局验证通过：使用预估尺寸 \(flowLayout.estimatedItemSize)", level: .info)
        } else {
            TFYUtils.Logger.log("布局验证警告：预估尺寸无效", level: .warning)
            flowLayout.estimatedItemSize = CGSize(width: 300, height: 120)
        }
        
        // 检查间距是否有效
        if flowLayout.minimumLineSpacing < 0 {
            flowLayout.minimumLineSpacing = 16
        }
        if flowLayout.minimumInteritemSpacing < 0 {
            flowLayout.minimumInteritemSpacing = 16
        }
        
        TFYUtils.Logger.log("布局配置验证通过", level: .info)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        TFYUtils.Logger.log("开始加载JSON数据", level: .info)
        
        // 使用TFYSwiftCategoryUtil的异步处理和JSON解析工具
        TFYAsynce.async(qos: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            // 使用TFYSwiftCategoryUtil的JSON解析工具
            if let jsonData = self.loadJSONData() {
                // 首先尝试解析完整的响应结构
                let responseResult = TFYSwiftJsonKit.decode(VIPProductResponse.self, from: jsonData)
                
                switch responseResult {
                case .success(let response):
                    self.vipResponse = response
                    self.vipData = response.data
                    self.allProducts = response.data.allProducts
                    
                    // 使用TFYSwiftCategoryUtil的图片处理工具处理产品图片
                    self.processProductImages()
                    
                    // 使用TFYSwiftJsonKit的格式化功能记录数据
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        let prettyResult = TFYSwiftJsonKit.prettyPrint(jsonString)
                        switch prettyResult {
                        case .success(let prettyJson):
                            TFYUtils.Logger.log("格式化JSON数据:\n\(prettyJson)", level: .debug)
                        case .failure(let error):
                            TFYUtils.Logger.log("JSON格式化失败: \(error.localizedDescription)", level: .warning)
                        }
                    }
                case .failure(let error):
                    TFYUtils.Logger.log("JSON响应解析失败: \(error.localizedDescription)", level: .error)
                    
                    // 尝试直接解析数据部分
                    let dataResult = TFYSwiftJsonKit.decode(VIPProductData.self, from: jsonData)
                    switch dataResult {
                    case .success(let data):
                        self.vipData = data
                        self.allProducts = data.allProducts
                        TFYUtils.Logger.log("直接数据解析成功，共\(self.allProducts.count)个产品", level: .info)
                        self.processProductImages()
                    case .failure(let dataError):
                        TFYUtils.Logger.log("直接数据解析也失败: \(dataError.localizedDescription)", level: .error)
                    }
                }
            } else {
                TFYUtils.Logger.log("JSON文件不存在，使用模拟数据", level: .warning)
            }
        } mainBlock: { [weak self] in
            self?.collectionView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - 图片处理
    private func processProductImages() {
        // 使用TFYSwiftCategoryUtil的图片处理工具
        TFYAsynce.async(qos: .background) { [weak self] in
            guard let self = self else { return }
            
            // 处理产品图片
            for (_, product) in self.allProducts.enumerated() {
                if let cycleProduct = product as? VIPCycleProduct {
                    // 使用TFYSwiftCategoryUtil的图片处理功能
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
                    if let image = UIImage(systemName: "crown.fill", withConfiguration: config) {
                        _ = image.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
                            .resizeImage(reSize: CGSize(width: 100, height: 100))
                            .image(corners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
                            .compressSize()
                        
                        TFYUtils.Logger.log("处理VIP产品图片: \(cycleProduct.productName)", level: .debug)
                    }
                } else if let coinProduct = product as? VIPCoinProduct {
                    let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
                    if let image = UIImage(systemName: "dollarsign.circle.fill", withConfiguration: config) {
                        _ = image.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
                            .resizeImage(reSize: CGSize(width: 100, height: 100))
                            .image(corners: .allCorners, cornerRadii: CGSize(width: 8, height: 8))
                            .compressSize()
                        
                        TFYUtils.Logger.log("处理金币产品图片: \(coinProduct.productName)", level: .debug)
                    }
                }
            }
            
            // 使用TFYSwiftJsonKit的模型转换功能
            if let data = self.vipData {
                let dictResult = TFYSwiftJsonKit.dictionary(from: data)
                switch dictResult {
                case .success(let dict):
                    TFYUtils.Logger.log("数据模型转字典成功，包含\(dict.keys.count)个字段", level: .debug)
                case .failure(let error):
                    TFYUtils.Logger.log("数据模型转字典失败: \(error.localizedDescription)", level: .warning)
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func refreshData() {
        TFYUtils.Logger.log("用户触发刷新", level: .info)
        // 使用TFYSwiftCategoryUtil的防抖功能
        TFYTimer.debounce(interval: .milliseconds(500), identifier: "refreshData") { [weak self] in
            self?.loadData()
        }
    }
    
    @objc private func changeLayout() {
        // 使用TFYSwiftCategoryUtil的AlertController和节流功能
        TFYTimer.throttle(interval: .milliseconds(300), identifier: "changeLayout") { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController.createSheet(
                title: "选择布局",
                message: "选择不同的自适应布局模式",
                items: ["完全自适应", "高性能自适应", "网格布局", "列表布局", "卡片布局", "取消"]
            ) { [weak self] _, action in
                guard let self = self else { return }
                
                switch action.title {
                case "完全自适应":
                    self.applyAutoSizingLayout()
                case "高性能自适应":
                    self.applyHighPerformanceLayout()
                case "网格布局":
                    self.applyGridLayout()
                case "列表布局":
                    self.applyListLayout()
                case "卡片布局":
                    self.applyCardLayout()
                default:
                    break
                }
            }
            
            self.present(alert, animated: true)
        }
    }
    
    private func createTestImages() -> [UIImage] {
        var images: [UIImage] = []
        
        // 使用TFYSwiftCategoryUtil的颜色工具创建测试图片
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow,
            .systemOrange, .systemPurple, .systemPink, .systemTeal
        ]
        
        for (index, color) in colors.enumerated() {
            // 创建简单的纯色图片
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = image {
                images.append(image)
                TFYUtils.Logger.log("创建测试图片 \(index + 1): \(color)", level: .debug)
            }
        }
        
        return images
    }
    
    private func showStitchResult() {
        // 使用TFYSwiftCategoryUtil的弹窗系统显示拼接结果
        let resultView = UIView()
            .tfy
            .backgroundColor(.systemBackground)
            .cornerRadius(16)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        let titleLabel = UILabel()
            .tfy
            .text("图片拼接演示")
            .font(.systemFont(ofSize: 18, weight: .bold))
            .textColor(.label)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        let messageLabel = UILabel()
            .tfy
            .text("使用TFYSwiftCategoryUtil的图片拼接工具成功处理了8张测试图片")
            .font(.systemFont(ofSize: 14))
            .textColor(.secondaryLabel)
            .numberOfLines(0)
            .textAlignment(.center)
            .translatesAutoresizingMaskIntoConstraints(false)
            .build
        
        resultView.addSubview(titleLabel)
        resultView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            resultView.widthAnchor.constraint(equalToConstant: 300),
            resultView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: resultView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: resultView.bottomAnchor, constant: -20)
        ])
        
        let popup = TFYSwiftPopupView(
            containerView: view,
            contentView: resultView,
            configuration: createPopupConfiguration()
        )
        
        popup.show()
    }
    
    private func createPopupConfiguration() -> TFYSwiftPopupViewConfiguration {
        var config = TFYSwiftPopupViewConfiguration()
        config.isDismissible = true
        config.isInteractive = true
        config.animationDuration = 0.3
        config.cornerRadius = 16
        config.shadowConfiguration.isEnabled = true
        config.shadowConfiguration.color = .black
        config.shadowConfiguration.opacity = 0.3
        config.shadowConfiguration.radius = 10
        return config
    }
    
    // MARK: - Layout Methods
    private func applyAutoSizingLayout() {
        currentLayoutType = "完全自适应"
        
        // 直接配置FlowLayout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            flowLayout.estimatedItemSize = CGSize(width: 300, height: 120)
        }
        
        updateTitle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        TFYUtils.Logger.log("切换到完全自适应布局", level: .info)
    }
    
    private func applyHighPerformanceLayout() {
        currentLayoutType = "高性能自适应"
        
        // 直接配置FlowLayout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            flowLayout.estimatedItemSize = CGSize(width: 300, height: 120)
        }
        
        updateTitle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        TFYUtils.Logger.log("切换到高性能自适应布局", level: .info)
    }
    
    private func applyGridLayout() {
        currentLayoutType = "网格布局"
        
        // 直接配置FlowLayout为网格布局
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let availableWidth = collectionView.bounds.width - 40 // 减去左右边距
            let itemWidth = (availableWidth - 16) / 2 // 2列，减去间距
            let itemHeight: CGFloat = 150
            
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 16
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            flowLayout.estimatedItemSize = .zero // 禁用自适应
        }
        
        updateTitle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        TFYUtils.Logger.log("切换到网格布局", level: .info)
    }
    
    private func applyListLayout() {
        currentLayoutType = "列表布局"
        
        // 直接配置FlowLayout为列表布局
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 12
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            flowLayout.estimatedItemSize = CGSize(width: 300, height: 100)
        }
        
        updateTitle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        TFYUtils.Logger.log("切换到列表布局", level: .info)
    }
    
    private func applyCardLayout() {
        currentLayoutType = "卡片布局"
        
        // 直接配置FlowLayout为卡片布局
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cardWidth = collectionView.bounds.width - 40 // 减去左右边距
            let cardHeight: CGFloat = 180
            
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 20
            flowLayout.minimumInteritemSpacing = 20
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            flowLayout.itemSize = CGSize(width: cardWidth, height: cardHeight)
            flowLayout.estimatedItemSize = .zero // 禁用自适应
        }
        
        updateTitle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        TFYUtils.Logger.log("切换到卡片布局", level: .info)
    }
    
    private func updateTitle() {
        title = "JSON自适应布局 (\(currentLayoutType))"
        
        // 调试信息
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            TFYUtils.Logger.log("布局更新 - 类型: \(currentLayoutType), 预估尺寸: \(flowLayout.estimatedItemSize), 项目尺寸: \(flowLayout.itemSize)", level: .debug)
        }
    }
    
    private func loadJSONData() -> Data? {
        // 首先尝试使用Dictionary+Chain.swift中的pathForResource方法加载本地JSON
        if let jsonDict = Dictionary<String, Any>.pathForResource(name: "content", ofType: "json") {
            TFYUtils.Logger.log("成功使用Dictionary.pathForResource加载content.json", level: .info)
            
            // 将字典转换为Data
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                return jsonData
            } catch {
                TFYUtils.Logger.log("字典转Data失败: \(error.localizedDescription)", level: .error)
            }
        }
        return nil
    }
}

// MARK: - UICollectionViewDataSource
extension JSONAdaptiveDemoController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(cell: VIPProductCell.self, for: indexPath)
        cell.configure(with: allProducts[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension JSONAdaptiveDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 使用TFYSwiftCategoryUtil的AlertController显示产品详情
        var title = ""
        var message = ""
        
        if let cycleProduct = allProducts[indexPath.item] as? VIPCycleProduct {
            title = cycleProduct.productName
            message = "价格: $\(cycleProduct.amount)\n描述: \(cycleProduct.productSubscript)"
        } else if let coinProduct = allProducts[indexPath.item] as? VIPCoinProduct {
            title = coinProduct.productName
            message = "价格: $\(coinProduct.amount)\n金币: \(coinProduct.totalCoins)\n描述: \(coinProduct.productSubscript)"
        }
        
        UIAlertController.showAlert(
            title,
            message: message,
            actionTitles: ["确定", "购买"],
            handler: { _, action in
                if action.title == "购买" {
                    TFYUtils.Logger.log("用户点击购买: \(title)", level: .info)
                }
            })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JSONAdaptiveDemoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 300, height: 120)
        }
        
        // 根据当前布局类型返回不同的尺寸
        switch currentLayoutType {
        case "完全自适应", "高性能自适应", "列表布局":
            // 使用自适应尺寸
            let availableWidth = collectionView.bounds.width - 40
            return CGSize(width: availableWidth, height: UICollectionViewFlowLayout.automaticSize.height)
            
        case "网格布局":
            // 网格布局使用固定尺寸
            let availableWidth = collectionView.bounds.width - 40
            let itemWidth = (availableWidth - 16) / 2
            return CGSize(width: itemWidth, height: 150)
            
        case "卡片布局":
            // 卡片布局使用固定尺寸
            let cardWidth = collectionView.bounds.width - 40
            return CGSize(width: cardWidth, height: 180)
            
        default:
            // 默认自适应
            let availableWidth = collectionView.bounds.width - 40
            return CGSize(width: availableWidth, height: UICollectionViewFlowLayout.automaticSize.height)
        }
    }
} 
