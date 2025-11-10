import Foundation

// TODO: localization, unit tests, proper error naming (instead of other)

enum KomojuError: Error, Equatable {
    static func == (lhs: KomojuError, rhs: KomojuError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }

    case invalidInput(FieldAndMessage)
    case network(Error)
    case notConfigured
    case other(String)
    case paymentNotCaptured(status: String)
    case serverError(FieldAndMessage)
}

extension KomojuError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidInput(let error):
            return error.message
        case .network(let error):
            return error.localizedDescription
        case .notConfigured:
            return "KomojuSDK not configured. Call configure(apiKey:) first."
        case .other(let description):
            return description
        case .paymentNotCaptured(let status):
            return "Payment was not captured. Status: " + status
        case .serverError(let error):
            return error.message
        }
    }
}

struct FieldAndMessage {
    let field: String?
    let message: String
}
