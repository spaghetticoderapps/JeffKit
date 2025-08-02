//
//  FeatureFlagManager.swift
//  JeffKit
//
//  Created by Jeff Cedilla on 6/8/25.
//

import Foundation

public struct FeatureFlagConfig: Codable, Sendable {
    public let featureFlags: [String: FeatureFlag]
    public let appConfig: AppConfig
    
    public init(featureFlags: [String: FeatureFlag], appConfig: AppConfig) {
        self.featureFlags = featureFlags
        self.appConfig = appConfig
    }
    
    enum CodingKeys: String, CodingKey {
        case featureFlags = "feature_flags"
        case appConfig = "app_config"
    }
}

public struct FeatureFlag: Codable, Sendable {
    public let enabled: Bool
    public let description: String
    
    public init(enabled: Bool, description: String) {
        self.enabled = enabled
        self.description = description
    }
}

public struct AppConfig: Codable, Sendable {
    public let minimumSupportedVersion: String
    public let forceUpdateRequired: Bool
    public let maintenanceMode: Bool
    public let apiEndpoints: APIEndpoints
    
    public init(minimumSupportedVersion: String, forceUpdateRequired: Bool, maintenanceMode: Bool, apiEndpoints: APIEndpoints) {
        self.minimumSupportedVersion = minimumSupportedVersion
        self.forceUpdateRequired = forceUpdateRequired
        self.maintenanceMode = maintenanceMode
        self.apiEndpoints = apiEndpoints
    }
    
    enum CodingKeys: String, CodingKey {
        case minimumSupportedVersion = "minimum_supported_version"
        case forceUpdateRequired = "force_update_required"
        case maintenanceMode = "maintenance_mode"
        case apiEndpoints = "api_endpoints"
    }
}

public struct APIEndpoints: Codable, Sendable {
    public let feedbackUrl: String
    public let supportUrl: String
    
    public init(feedbackUrl: String, supportUrl: String) {
        self.feedbackUrl = feedbackUrl
        self.supportUrl = supportUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case feedbackUrl = "feedback_url"
        case supportUrl = "support_url"
    }
}

@MainActor
public class FeatureFlagManager: ObservableObject, Sendable {
    public static let shared = FeatureFlagManager()
    
    @Published private var config: FeatureFlagConfig?
    
    private let remoteURL: String
    private let appName: String
    private let cacheKey: String
    private let lastUpdateKey: String
    private let cacheValidityHours: TimeInterval
    
    public convenience init() {
        self.init(
            remoteURL: "https://raw.githubusercontent.com/spaghetticoderapps/FeatureFlags/main/feature-flags.yaml",
            appName: "worktracker",
            cacheValidityHours: 1
        )
    }
    
    public init(remoteURL: String, appName: String, cacheValidityHours: TimeInterval = 1) {
        self.remoteURL = remoteURL
        self.appName = appName
        self.cacheValidityHours = cacheValidityHours
        self.cacheKey = "feature_flags_cache_\(appName)"
        self.lastUpdateKey = "feature_flags_last_update_\(appName)"
        
        loadCachedConfig()
        fetchRemoteConfig()
    }
    
    // MARK: - Public Methods
    
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return config?.featureFlags[feature]?.enabled ?? false
    }
    
    public func getFeatureDescription(_ feature: String) -> String {
        return config?.featureFlags[feature]?.description ?? ""
    }
    
    public func getAppConfig() -> AppConfig? {
        return config?.appConfig
    }
    
    public func refreshConfig() {
        fetchRemoteConfig()
    }
    
    // MARK: - Private Methods
    
    private func loadCachedConfig() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date,
              Date().timeIntervalSince(lastUpdate) < cacheValidityHours * 3600,
              let config = try? JSONDecoder().decode(FeatureFlagConfig.self, from: data) else {
            return
        }
        
        self.config = config
    }
    
    private func fetchRemoteConfig() {
        guard let url = URL(string: remoteURL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("Failed to fetch feature flags: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            Task { @MainActor in
                self.parseYAMLData(data)
            }
        }.resume()
    }
    
    private func parseYAMLData(_ data: Data) {
        guard let yamlString = String(data: data, encoding: .utf8) else {
            print("Failed to convert data to string")
            return
        }
        
        // Parse YAML manually for the specified app section
        guard let appConfig = extractAppConfig(from: yamlString, appName: appName) else {
            print("Failed to extract \(appName) config from YAML")
            return
        }
        
        // Convert to JSON for easier parsing
        guard let jsonData = try? JSONSerialization.data(withJSONObject: appConfig),
              let config = try? JSONDecoder().decode(FeatureFlagConfig.self, from: jsonData) else {
            print("Failed to decode feature flag config")
            return
        }
        
        // Cache the config
        UserDefaults.standard.set(jsonData, forKey: cacheKey)
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
        
        self.config = config
    }
    
    private func extractAppConfig(from yamlString: String, appName: String) -> [String: Any]? {
        let lines = yamlString.components(separatedBy: .newlines)
        var appSection: [String: Any] = [:]
        var currentSection: [String: Any] = [:]
        var currentFeatureFlags: [String: [String: Any]] = [:]
        var isInApps = false
        var isInApp = false
        var isInFeatureFlags = false
        var isInAppConfig = false
        var currentFeature: String?
        var appConfig: [String: Any] = [:]
        var apiEndpoints: [String: Any] = [:]
        var isInApiEndpoints = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // First look for "apps:" section
            if trimmedLine.hasPrefix("apps:") {
                isInApps = true
                continue
            }
            
            if !isInApps { continue }
            
            // Then look for the specific app name within apps
            if trimmedLine.hasPrefix("\(appName):") && line.hasPrefix("  ") {
                isInApp = true
                continue
            }
            
            if !isInApp { continue }
            
            // Stop if we hit another app or top-level section
            if line.hasPrefix("  ") && !line.hasPrefix("    ") && trimmedLine.hasSuffix(":") && !trimmedLine.hasPrefix("#") && trimmedLine != "feature_flags:" && trimmedLine != "app_config:" {
                break
            }
            
            if trimmedLine.hasPrefix("feature_flags:") {
                isInFeatureFlags = true
                isInAppConfig = false
                continue
            }
            
            if trimmedLine.hasPrefix("app_config:") {
                isInFeatureFlags = false
                isInAppConfig = true
                continue
            }
            
            if isInFeatureFlags {
                if trimmedLine.hasPrefix("# ") || trimmedLine.isEmpty {
                    continue
                }
                
                if line.hasPrefix("        ") && trimmedLine.contains(":") {
                    // Feature property (enabled/description)
                    let components = trimmedLine.components(separatedBy: ": ")
                    if components.count == 2, let feature = currentFeature {
                        let key = components[0]
                        let value = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                        
                        if key == "enabled" {
                            currentFeatureFlags[feature, default: [:]][key] = value == "true"
                        } else {
                            currentFeatureFlags[feature, default: [:]][key] = value
                        }
                    }
                } else if line.hasPrefix("      ") && trimmedLine.hasSuffix(":") {
                    // New feature
                    currentFeature = String(trimmedLine.dropLast())
                    currentFeatureFlags[currentFeature!] = [:]
                }
            }
            
            if isInAppConfig {
                if trimmedLine.hasPrefix("api_endpoints:") {
                    isInApiEndpoints = true
                    continue
                }
                
                if isInApiEndpoints {
                    if line.hasPrefix("        ") && trimmedLine.contains(":") {
                        let components = trimmedLine.components(separatedBy: ": ")
                        if components.count == 2 {
                            let key = components[0]
                            let value = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                            apiEndpoints[key] = value
                        }
                    }
                } else if line.hasPrefix("      ") && trimmedLine.contains(":") {
                    let components = trimmedLine.components(separatedBy: ": ")
                    if components.count == 2 {
                        let key = components[0]
                        let value = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                        
                        if key == "force_update_required" || key == "maintenance_mode" {
                            appConfig[key] = value == "true"
                        } else {
                            appConfig[key] = value
                        }
                    }
                }
            }
        }
        
        if !apiEndpoints.isEmpty {
            appConfig["api_endpoints"] = apiEndpoints
        }
        
        appSection["feature_flags"] = currentFeatureFlags
        appSection["app_config"] = appConfig
        
        return appSection
    }
}
