import Foundation

// TODO: support other payments, such as Credit Card Brazil, Korea, etc

public final actor KomojuSDK {
    public static let shared = KomojuSDK()

    private var apiClient: APIClient?
    private var isConfigured = false

    init() {}

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    /// Call this before using KomojuSDK in order to configure it.
    /// - Parameter apiKey: The api key needed for Komoju API
    public func configure(apiKey: String) {
        guard !isConfigured else { return }
        self.isConfigured = true
        if self.apiClient == nil {
            self.apiClient = APIClientLive(apiKey: apiKey)
        }
    }

    /// Call this to make a credit card payment
    /// - Parameters:
    ///   - amount: The payment amount in the lowest denomination of the currency (e.g. cents for USD)
    ///   - currency: Currency of the payment
    ///   - creditCardDetails: The details of the credit card being used for payment
    public func makeCreditCardPayment(
        amount: Int,
        currency: Currency,
        creditCardDetails: CreditCardDetails
    ) async throws {
        guard let apiClient else {
            throw KomojuError.notConfigured
        }

        guard amount > 0 else {
            throw KomojuError.invalidInput(.init(field: "amount", message: "Payment amount must be greater than 0."))
        }

        try creditCardDetails.validate()

        let customerIp = try await getPublicIp()
        let payment = Payment(
            amount: amount,
            currency: currency,
            fraudDetails: .init(customerIp: customerIp),
            paymentDetails: .init(
                email: creditCardDetails.email,
                month: creditCardDetails.expirationMonth,
                name: creditCardDetails.name,
                number: creditCardDetails.number,
                type: .creditCard,
                verificationValue: creditCardDetails.verificationValue,
                year: creditCardDetails.expirationYear
            )
        )

        do {
            let response = try await apiClient.makePaymentRequest(with: payment)

            if response.status != .captured {
                throw KomojuError.paymentNotCaptured(status: response.status.rawValue)
            }
        } catch let error as APIClientError {
            // Convert internal errors to public error

            switch error {
            case .invalidResponse:
                throw KomojuError.other("The response from the server was invalid.")
            case .decodingFailed:
                throw KomojuError.other("The response from the server could not be decoded.")
            case .serverError(let error):
                throw KomojuError.serverError(error)
            case .network(let error):
                throw KomojuError.network(error)
            }
        } catch {
            throw KomojuError.other(error.localizedDescription)
        }
    }

    private func getPublicIp() async throws -> String {
        guard let apiClient else {
            preconditionFailure("KomojuSDK not configured. Call configure(apiKey:) first.")
        }

        return try await apiClient.makeIpRequest().ip
    }
}
