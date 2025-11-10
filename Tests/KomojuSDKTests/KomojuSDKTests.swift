import Testing
@testable import KomojuSDK

@Suite("KomojuSDK Tests")
struct KomojuSDKTests {
    @Test("Succeeds when valid data is provided and payment is captured")
    func testSuccessfulPayment() async throws {
        let mockClient = MockAPIClient(
            ipResponse: .success(.init(ip: "1.2.3.4")),
            paymentResponse: .success(.init(status: .captured))
        )
        let komoju = KomojuSDK(apiClient: mockClient)
        await komoju.configure(apiKey: "test_key")

        let validCard = CreditCardDetails.validSample()
        try await komoju.makeCreditCardPayment(amount: 1000, currency: .USD, creditCardDetails: validCard)
    }

    @Test("Throws when SDK not configured")
    func testUnconfiguredSDK() async {
        let komoju = KomojuSDK()
        let card = CreditCardDetails.validSample()

        await #expect(throws: KomojuError.notConfigured) {
            try await komoju.makeCreditCardPayment(amount: 1000, currency: .USD, creditCardDetails: card)
        }
    }

    @Test("Throws invalid amount error")
    func testInvalidAmount() async throws {
        let mockClient = MockAPIClient(
            ipResponse: .success(.init(ip: "1.2.3.4")),
            paymentResponse: .success(.init(status: .captured))
        )
        let komoju = KomojuSDK(apiClient: mockClient)
        await komoju.configure(apiKey: "test_key")

        let card = CreditCardDetails.validSample()
        await #expect(throws:
            KomojuError.invalidInput(.init(
                field: "amount",
                message: "Payment amount must be greater than 0."
            ))
        ) {
            try await komoju.makeCreditCardPayment(amount: 0, currency: .USD, creditCardDetails: card)
        }
    }

    @Test("Throws when validation of card details input fails")
    func testCardValidationFailure() async throws {
        let mockClient = MockAPIClient(
            ipResponse: .success(.init(ip: "1.2.3.4")),
            paymentResponse: .success(.init(status: .captured))
        )
        let sdk = KomojuSDK(apiClient: mockClient)
        await sdk.configure(apiKey: "test_key")

        let invalidCard = CreditCardDetails(
            email: "",
            name: "",
            number: "123",
            expirationMonth: 1,
            expirationYear: 2020,
            verificationValue: ""
        )

        await #expect(throws:
            KomojuError.invalidInput(.init(
                field: "name",
                message: "Cardholder name is required."
            ))
        ) {
            try await sdk.makeCreditCardPayment(amount: 1000, currency: .USD, creditCardDetails: invalidCard)
        }
    }

    @Test("Throws when payment not captured")
    func testPaymentNotCaptured() async throws {
        let paymentStatus = PaymentRequestResponse.Status.pending
        let mockClient = MockAPIClient(
            ipResponse: .success(.init(ip: "1.2.3.4")),
            paymentResponse: .success(.init(status: paymentStatus))
        )
        let sdk = KomojuSDK(apiClient: mockClient)
        await sdk.configure(apiKey: "test_key")

        let card = CreditCardDetails.validSample()
        await #expect(throws: KomojuError.paymentNotCaptured(status: paymentStatus.rawValue) ) {
            try await sdk.makeCreditCardPayment(amount: 1000, currency: .USD, creditCardDetails: card)
        }
    }

    @Test("Converts network error correctly")
    func testNetworkError() async throws {
        struct DummyError: Error {}
        let error = DummyError()
        let mockClient = MockAPIClient(
            ipResponse: .success(.init(ip: "1.2.3.4")),
            paymentResponse: .failure(error)
        )
        let sdk = KomojuSDK(apiClient: mockClient)
        await sdk.configure(apiKey: "test_key")

        let card = CreditCardDetails.validSample()
        await #expect(throws: KomojuError.network(error) ) {
            try await sdk.makeCreditCardPayment(amount: 1000, currency: .USD, creditCardDetails: card)
        }
    }
}

struct MockAPIClient: APIClient {
    var ipResponse: Result<IpRequestResponse, Error>
    var paymentResponse: Result<PaymentRequestResponse, Error>

    func makeIpRequest() async throws -> IpRequestResponse {
        try ipResponse.get()
    }

    func makePaymentRequest(with payment: Payment) async throws -> PaymentRequestResponse {
        try paymentResponse.get()
    }
}

extension CreditCardDetails {
    static func validSample() -> Self {
        .init(
            email: "test@example.com",
            name: "John Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2030,
            verificationValue: "123"
        )
    }
}
