import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        customizeAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 只在第一次布局时设置透明度效果
        setupTabBarTransparency()
    }
    
    private func setupViewControllers() {
        let homeVC = HomeController()
        let discoverVC = ViewController()
        let messageVC = GCDSocketController()
        let profileVC = AdaptiveDemoController()
        let windowCleanerVC = MultilingualClickTestController()
        // 包装到导航控制器中
        let homeNav = createNavigationController(rootViewController: homeVC,
                                                  title: "首页",
                                                  image: UIImage(systemName: "house"),
                                                  selectedImage: UIImage(systemName: "house.fill"))
        
        let discoverNav = createNavigationController(rootViewController: discoverVC,
                                                      title: "功能",
                                                      image: UIImage(systemName: "square.grid.2x2"),
                                                      selectedImage: UIImage(systemName: "square.grid.2x2.fill"))
        
        let messageNav = createNavigationController(rootViewController: messageVC,
                                                     title: "弹窗",
                                                     image: UIImage(systemName: "rectangle.stack"),
                                                     selectedImage: UIImage(systemName: "rectangle.stack.fill"))
        
        let profileNav = createNavigationController(rootViewController: profileVC,
                                                     title: "适配",
                                                     image: UIImage(systemName: "iphone.landscape"),
                                                     selectedImage: UIImage(systemName: "iphone.landscape"))
        
        let windowCleanerNav = createNavigationController(rootViewController: windowCleanerVC,
                                                     title: "清理",
                                                     image: UIImage(systemName: "trash.circle"),
                                                     selectedImage: UIImage(systemName: "trash.circle.fill"))
        
        // 设置标签栏控制器的视图控制器数组
        viewControllers = [homeNav, discoverNav, messageNav, profileNav,windowCleanerNav]
    }
    
    private func createNavigationController(rootViewController: UIViewController,
                                           title: String,
                                           image: UIImage?,
                                           selectedImage: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.selectedImage = selectedImage
        rootViewController.navigationItem.title = title
        return navigationController
    }
    
    private func customizeAppearance() {
        // 设置标签栏选中颜色
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .systemGray
        
        // iOS 15+ 需要使用新的 appearance API
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // 设置标签栏项目的外观
            appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    /// 设置TabBar透明度效果
    private func setupTabBarTransparency() {
        for view in view.getTabBarPlatterViews("_UITabBarContainerWrapperView") {
            view.backgroundColor = .clear
        }
        for view in tabBar.getTabBarPlatterViews("_UITabBarPlatterView") {
            view.backgroundColor = .clear
        }
    }
    
    // MARK: - Orientation Support
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if TFYSwiftAdaptiveKit.Device.isIPad {
            return .all
        } else {
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool {
        return TFYSwiftAdaptiveKit.Device.isIPad
    }
}
