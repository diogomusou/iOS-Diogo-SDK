import Foundation

// TODO: add unit test

extension URLRequest {
    static func paymentRequest(with payment: Payment, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: "https://komoju.com/api/v1/payments") else {
            preconditionFailure("Invalid hardcoded URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Body
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(payment)

        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let credentials = "\(apiKey):"
        if let credentialData = credentials.data(using: .utf8) {
            let base64Credentials = credentialData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

struct PaymentRequestResponse: Decodable {
    enum Status: String, Decodable {
        case pending
        case authorized
        case captured
        case cancelled
        case expired
        case refunded
        case failed
    }
    let status: Status
}

struct PaymentRequestErrorResponse: Decodable {
    struct Details: Decodable {
        let code: String
        let message: String
        let param: String?
        let details: [String: String]?
    }

    let error: Details
}

extension PaymentRequestErrorResponse {
    var fieldAndMessage: FieldAndMessage {
        func cleanParameterName(_ param: String?) -> String? {
            guard
                let param = param,
                let range = param.range(of: #"(?<=\[).*(?=\])"#, options: .regularExpression)
            else { return nil }

            return String(param[range])
        }

        return .init(
            field: cleanParameterName(error.param),
            message: error.message
        )
    }
}
