import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        customizeAppearance()
    }
    
    private func setupViewControllers() {
        let homeVC = HomeController()
        homeVC.tabBarItem = UITabBarItem(
            title: "首页", 
            image: UIImage(systemName: "house"), 
            selectedImage: UIImage(systemName: "house.fill")
        )
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        let viewVC = ViewController()
        viewVC.tabBarItem = UITabBarItem(
            title: "功能", 
            image: UIImage(systemName: "square.grid.2x2"), 
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )
        let viewNav = UINavigationController(rootViewController: viewVC)
        
        let socketVC = GCDSocketController()
        socketVC.tabBarItem = UITabBarItem(
            title: "弹窗", 
            image: UIImage(systemName: "rectangle.stack"), 
            selectedImage: UIImage(systemName: "rectangle.stack.fill")
        )
        let socketNav = UINavigationController(rootViewController: socketVC)
        
        let adaptiveVC = UICollectionViewAdaptiveDemoController()
        adaptiveVC.tabBarItem = UITabBarItem(
            title: "适配", 
            image: UIImage(systemName: "iphone.landscape"), 
            selectedImage: UIImage(systemName: "iphone.landscape")
        )
        let adaptiveNav = UINavigationController(rootViewController: adaptiveVC)
        
        viewControllers = [homeNav, viewNav, socketNav, adaptiveNav]
    }
    
    private func customizeAppearance() {
        // 适配不同设备的外观
        if TFYSwiftAdaptiveKit.Device.isIPad {
            // iPad样式
            tabBar.tintColor = .systemBlue
            tabBar.backgroundColor = .systemBackground
            tabBar.unselectedItemTintColor = .systemGray
        } else {
            // iPhone样式
            tabBar.tintColor = .systemBlue
            tabBar.backgroundColor = .systemBackground
            tabBar.unselectedItemTintColor = .systemGray2
        }
        
        // 设置TabBar外观
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = tabBar.backgroundColor
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
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
