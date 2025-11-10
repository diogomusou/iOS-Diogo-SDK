public protocol KomojuPaymentService: Sendable {
    func makeCreditCardPayment(
        amount: Int,
        currency: Currency,
        creditCardDetails: CreditCardDetails
    ) async throws
}

extension KomojuSDK: KomojuPaymentService {}
