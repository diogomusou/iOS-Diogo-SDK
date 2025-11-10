struct Payment: Codable {
    let amount: Int
    let currency: Currency
    let fraudDetails: FraudDetails
    let paymentDetails: PaymentDetails
}

struct PaymentDetails: Codable {
    enum `Type`: String, Codable {
        case creditCard = "credit_card"
    }
    let email: String
    let month: Int
    let name: String
    let number: String
    let type: `Type`
    let verificationValue: String
    let year: Int
}

struct FraudDetails: Codable {
    let customerIp: String
}
