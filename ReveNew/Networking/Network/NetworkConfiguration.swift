import Foundation

class NetworkConfiguration {
    static let shared = NetworkConfiguration()
    
    private var host: String?
    private var port: Int?
    
    private init() {}
    
    func configure(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func getHost() -> String {
        guard let host = host else {
            fatalError("Network host not configured. Please call NetworkConfiguration.shared.configure(host:port:) before making any network requests. --> Check ReveNewApp.swift and set it inside the init")
        }
        return host
    }
    
    func getPort() -> Int {
        guard let port = port else {
            fatalError("Network port not configured. Please call NetworkConfiguration.shared.configure(host:port:) before making any network requests. --> Check ReveNewApp.swift and set it inside the init")
        }
        return port
    }
    
    var isConfigured: Bool {
        return host != nil && port != nil
    }
} 
