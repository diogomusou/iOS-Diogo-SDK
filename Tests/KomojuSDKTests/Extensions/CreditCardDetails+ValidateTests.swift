import Foundation
import Testing
@testable import KomojuSDK

// TODO: test with other calendars

@Suite("Credit Card Validation Tests")
struct CreditCardDetailsValidationTests {
    let fixedDate = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2025, month: 6, day: 15))!

    // MARK: - Success case

    @Test("Valid card passes validation")
    func testValidCard() throws {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "123"
        )
        try card.validate(currentDate: fixedDate)
    }

    // MARK: - Name

    @Test("Empty name throws validation error")
    func testEmptyName() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "   ",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "123"
        )
        #expect(throws: KomojuError.invalidInput(.init(field: "name", message: "Cardholder name is required."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    // MARK: - Email

    @Test("Invalid email throws validation error")
    func testInvalidEmail() {
        let card = CreditCardDetails(
            email: "not-an-email",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "123"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "email", message: "Please enter a valid email address."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    // MARK: - Card number

    @Test("Invalid Luhn number throws validation error")
    func testInvalidLuhn() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "1234567890123",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "123"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "number", message: "Please enter a valid credit card number."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    @Test("Too short number throws validation error")
    func testShortCardNumber() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "42424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "123"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "number", message: "Please enter a valid credit card number."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    // MARK: - Expiration

    @Test("Expired card (past year) throws validation error")
    func testExpiredYear() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2023,
            verificationValue: "123"
        )
        #expect(throws: KomojuError.invalidInput(.init(field: "expirationYear", message: "This card is expired."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    @Test("Expired card (past month same year) throws validation error")
    func testExpiredMonth() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 3,
            expirationYear: 2025,
            verificationValue: "123"
        )
        #expect(throws: KomojuError.invalidInput(.init(field: "expirationYear", message: "This card is expired."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    @Test("Invalid month (<1 or >12) throws validation error")
    func testInvalidMonthRange() {
        let invalidMonthCard = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 0,
            expirationYear: 2025,
            verificationValue: "123"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "expirationMonth", message: "Expiration month must be between 1 and 12."))) {
            try invalidMonthCard.validate(currentDate: fixedDate)
        }
    }

    // MARK: - CVV

    @Test("Invalid CVV length throws validation error")
    func testInvalidCVVLength() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "12"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "verificationValue", message: "Invalid security code."))) {
            try card.validate(currentDate: fixedDate)
        }
    }

    @Test("Non-numeric CVV throws validation error")
    func testNonNumericCVV() {
        let card = CreditCardDetails(
            email: "user@example.com",
            name: "Jane Doe",
            number: "4242424242424242",
            expirationMonth: 12,
            expirationYear: 2026,
            verificationValue: "12A"
        )
        // swiftlint:disable:next line_length
        #expect(throws: KomojuError.invalidInput(.init(field: "verificationValue", message: "Invalid security code."))) {
            try card.validate(currentDate: fixedDate)
        }
    }
}
