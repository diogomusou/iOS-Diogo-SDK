import KomojuSDK
import SwiftUI

// TODO: localization, accessibility identifiers, support for more fields (billing address, etc)
// TODO: detect and autofill information from camera/image

public struct KomojuCreditCardFormView: View {

    @State private var viewModel: KomojuCreditCardFormViewModel

    public init(price: Int, currency: Currency, onPaymentCompleted: (() -> Void)? = nil) {
        viewModel = KomojuCreditCardFormViewModel(price: price, currency: currency)
    }

    public var body: some View {
        Form {
            Section(header: Text("Cardholder Information")) {
                TextField("Full Name", text: $viewModel.name)
                    .textContentType(.name)
                    .autocapitalization(.words)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section(header: Text("Card Details")) {
                TextField("Card Number", text: $viewModel.cardNumber)
                    .keyboardType(.numberPad)
                    .textContentType(.creditCardNumber)

                TextField("Security Code", text: $viewModel.securityCode)
                    .keyboardType(.numberPad)

                VStack(alignment: .leading) {
                    Text("Expiry Date")
                    HStack {
                        VStack(alignment: .leading) {
                            Picker("Month", selection: $viewModel.expiryMonth) {
                                ForEach(viewModel.months, id: \.self) { month in
                                    Text(String(format: "%02d", month)).tag(month)
                                }
                            }
                            .pickerStyle(.automatic)
                        }

                        VStack(alignment: .leading) {
                            Picker("Year", selection: $viewModel.expiryYear) {
                                ForEach(viewModel.years, id: \.self) { year in
                                    Text(verbatim: "\(year)").tag(year)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
            }

            Section {
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.vertical, 4)
                }
                if viewModel.didCompletePayment {
                    Text("Payment Successful!")
                        .foregroundColor(.green)
                        .font(.subheadline)
                        .padding(.vertical, 4)
                }
                Button {
                    Task {
                        await viewModel.submitButtonTapped()
                    }
                } label: {
                    Text("Submit Payment")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.submitButtonDisabled)
            }
        }
    }
}

#Preview {
    KomojuCreditCardFormView(price: 100, currency: .JPY)
}
