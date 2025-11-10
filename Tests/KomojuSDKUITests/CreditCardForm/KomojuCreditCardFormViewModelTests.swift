import Foundation
import KomojuSDK
import Testing
@testable import KomojuSDKUI

// MARK: - Mock Payment Service

actor MockPaymentService: KomojuPaymentService {
    enum Behavior {
        case succeed
        case fail(Error)
    }

    private let behavior: Behavior
    private(set) var callCount = 0
    private(set) var lastAmount: Int?
    private(set) var lastCurrency: Currency?
    private(set) var lastDetails: CreditCardDetails?

    init(behavior: Behavior) {
        self.behavior = behavior
    }

    func makeCreditCardPayment(
        amount: Int,
        currency: Currency,
        creditCardDetails: CreditCardDetails
    ) async throws {
        callCount += 1
        lastAmount = amount
        lastCurrency = currency
        lastDetails = creditCardDetails

        try await Task.sleep(for: .milliseconds(10))

        switch behavior {
        case .succeed:
            return
        case .fail(let error):
            throw error
        }
    }
}

// MARK: - Test Suite

@MainActor
@Suite("KomojuCreditCardFormViewModel Tests")
struct KomojuCreditCardFormViewModelTests {

    @Test("Payment completes successfully and triggers callback")
    func testSuccessfulPayment() async {
        var paymentCompleted = false
        let mock = MockPaymentService(behavior: .succeed)

        let viewModel = KomojuCreditCardFormViewModel(price: 1000, currency: .JPY, paymentService: mock) {
            paymentCompleted = true
        }

        await viewModel.submitButtonTapped()

        #expect(await mock.callCount == 1)
        #expect(paymentCompleted == true)
        #expect(viewModel.didCompletePayment)
        #expect(viewModel.error == nil)
        #expect(viewModel.submitButtonDisabled)
    }

    @Test("Payment fails and sets error message")
    func testPaymentFailureSetsError() async {
        struct TestError: LocalizedError {
            var errorDescription: String? { "Payment failed" }
        }

        let mock = MockPaymentService(behavior: .fail(TestError()))
        let viewModel = KomojuCreditCardFormViewModel(price: 500, currency: .USD, paymentService: mock)

        await viewModel.submitButtonTapped()

        #expect(await mock.callCount == 1)
        #expect(viewModel.didCompletePayment == false)
        #expect(viewModel.error == "Payment failed")
        #expect(viewModel.submitButtonDisabled == false)
    }

    @Test("Submit button is disabled after successful payment")
    func testSubmitButtonDisabledAfterPayment() async {
        let mock = MockPaymentService(behavior: .succeed)
        let viewModel = KomojuCreditCardFormViewModel(price: 200, currency: .EUR, paymentService: mock)

        #expect(viewModel.submitButtonDisabled == false)
        await viewModel.submitButtonTapped()
        #expect(viewModel.submitButtonDisabled == true)
    }

    @Test("Calling submit again after completion does nothing")
    func testRepeatedSubmitDoesNothing() async {
        let mock = MockPaymentService(behavior: .succeed)
        let viewModel = KomojuCreditCardFormViewModel(price: 200, currency: .CAD, paymentService: mock)

        await viewModel.submitButtonTapped()
        await viewModel.submitButtonTapped()

        #expect(await mock.callCount == 1)
    }

    @Test("Default expiryMonth, expiryYear and years range")
    func testInjectedDate() async {
        let fixedDate = Calendar.current.date(from: DateComponents(year: 2030, month: 8, day: 15))!

        let viewModel = KomojuCreditCardFormViewModel(price: 100, currency: .USD, currentDate: fixedDate)

        #expect(viewModel.expiryMonth == 8)
        #expect(viewModel.expiryYear == 2030)
        #expect(viewModel.years.first == 2030)
        #expect(viewModel.years.last == 2100)
        #expect(viewModel.months == Array(1...12))
    }
}
