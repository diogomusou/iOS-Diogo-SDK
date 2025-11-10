import Foundation

extension URLRequest {
    static var ipRequest: URLRequest {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            preconditionFailure("Invalid hardcoded URL")
        }

        return URLRequest(url: url)
    }
}

struct IpRequestResponse: Decodable {
    // swiftlint:disable:next identifier_name
    let ip: String
}
