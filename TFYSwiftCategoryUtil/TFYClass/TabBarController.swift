import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        customizeAppearance()
    }
    
    private func setupViewControllers() {
        let homeVC = HomeController()
        homeVC.tabBarItem = UITabBarItem(title: "首页", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        let homeNav = UINavigationController(rootViewController: homeVC)
        
        let viewVC = ViewController()
        viewVC.tabBarItem = UITabBarItem(title: "功能", image: UIImage(systemName: "square.grid.2x2"), selectedImage: UIImage(systemName: "square.grid.2x2.fill"))
        let viewNav = UINavigationController(rootViewController: viewVC)
        
        let socketVC = GCDSocketController()
        socketVC.tabBarItem = UITabBarItem(title: "网络", image: UIImage(systemName: "network"), selectedImage: UIImage(systemName: "network.fill"))
        let socketNav = UINavigationController(rootViewController: socketVC)
        
        viewControllers = [homeNav, viewNav, socketNav]
    }
    
    private func customizeAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
} 