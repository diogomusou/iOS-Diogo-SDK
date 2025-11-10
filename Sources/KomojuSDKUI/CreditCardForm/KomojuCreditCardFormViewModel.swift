import Foundation
import KomojuSDK

@MainActor
@Observable
final class KomojuCreditCardFormViewModel {
    var name = ""
    var email = ""
    var cardNumber = ""
    var securityCode = ""
    var expiryMonth: Int = Calendar.current.component(.month, from: Date())
    var expiryYear: Int = Calendar.current.component(.year, from: Date())

    var didCompletePayment = false
    var error: String?
    var submitButtonDisabled: Bool { isLoading || didCompletePayment }

    let months = Array(1...12)
    let years: [Int]

    private var isLoading = false
    private let price: Int
    private let currency: Currency
    private let paymentService: KomojuPaymentService
    private let onPaymentCompleted: (() -> Void)?

    init(
        price: Int,
        currency: Currency,
        currentDate: Date = Date(),
        paymentService: KomojuPaymentService = KomojuSDK.shared,
        onPaymentCompleted: (() -> Void)? = nil
    ) {
        self.price = price
        self.currency = currency
        self.paymentService = paymentService
        self.onPaymentCompleted = onPaymentCompleted

        let expiryYear = Calendar.current.component(.year, from: currentDate)
        self.expiryMonth = Calendar.current.component(.month, from: currentDate)
        self.expiryYear = expiryYear
        self.years = Array(expiryYear...2100)
    }

    func submitButtonTapped() async {
        guard !didCompletePayment else { return }

        defer {
            isLoading = false
        }

        do {
            error = nil
            isLoading = true
            try await paymentService.makeCreditCardPayment(
                amount: price,
                currency: currency,
                creditCardDetails: .init(
                    email: email,
                    name: name,
                    number: cardNumber,
                    expirationMonth: expiryMonth,
                    expirationYear: expiryYear,
                    verificationValue: securityCode
                )
            )

            didCompletePayment = true
            onPaymentCompleted?()

        } catch {
            self.error = error.localizedDescription
        }
    }
}
