func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 其他初始化代码...
    
    // 配置 VPN 后台监控
    TFYVPNBackgroundMonitor.shared.configure()
    
    return true
} 