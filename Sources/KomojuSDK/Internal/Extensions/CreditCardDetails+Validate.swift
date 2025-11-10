import Foundation

extension CreditCardDetails {
    func validate(currentDate: Date = .now, calendar: Calendar = .current) throws {
        // Name validation
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "name", message: "Cardholder name is required.")
            )
        }

        // Email validation
        if !email.isValidEmail {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "email", message: "Please enter a valid email address.")
            )
        }

        // Card number validation (Luhn + length)
        let digits = number.filter(\.isNumber)
        if digits.count < 12 || digits.count > 19 || !digits.isValidLuhn {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "number", message: "Please enter a valid credit card number.")
            )
        }

        // Expiration date validation
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        if expirationMonth < 1 || expirationMonth > 12 {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "expirationMonth", message: "Expiration month must be between 1 and 12.")
            )
        }

        if expirationYear < currentYear ||
            (expirationYear == currentYear && expirationMonth < currentMonth) {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "expirationYear", message: "This card is expired.")
            )
        }

        // Security code validation
        if verificationValue.count < 3 || verificationValue.count > 4 || !verificationValue.allSatisfy(\.isNumber) {
            throw KomojuError.invalidInput(
                FieldAndMessage(field: "verificationValue", message: "Invalid security code.")
            )
        }
    }
}

extension String {
    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
    }

    var isValidLuhn: Bool {
        var sum = 0
        let reversed = self.reversed().compactMap { Int(String($0)) }
        for (index, digit) in reversed.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
