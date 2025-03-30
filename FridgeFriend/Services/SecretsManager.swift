import Foundation

struct SecretsManager {
    static func getAPIKey(for key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        return dictionary[key] as? String
    }
}