// TODO: support more Komoju API parameters, like billing address, fraud details, etc

public struct CreditCardDetails: Sendable {
    let email: String
    let name: String
    let number: String
    let expirationMonth: Int
    let expirationYear: Int
    let verificationValue: String

    public init(
        email: String,
        name: String,
        number: String,
        expirationMonth: Int,
        expirationYear: Int,
        verificationValue: String
    ) {
        self.email = email
        self.name = name
        self.number = number
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.verificationValue = verificationValue
    }
}
