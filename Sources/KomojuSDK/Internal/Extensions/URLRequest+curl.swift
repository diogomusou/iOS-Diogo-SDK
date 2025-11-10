import Foundation

extension URLRequest {
    func curlString() -> String {
        var result = "curl -v \\\n"

        if let method = httpMethod {
            result += " -X \(method) \\\n"
        }

        for (key, value) in allHTTPHeaderFields ?? [:] {
            result += " -H '\(key): \(value)' \\\n"
        }

        if let body = httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            // Escape single quotes
            let escaped = bodyString.replacingOccurrences(of: "'", with: "'\\''")
            result += " -d '\(escaped)' \\\n"
        }

        if let url = url {
            result += " '\(url.absoluteString)'"
        }

        return result
    }
}
