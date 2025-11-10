# 💳 KomojuSDK

A lightweight, modern Swift SDK for processing credit card payments through [Komoju](https://doc.komoju.com/reference/createpayment).  
Built with Swift Concurrency, type-safe models, and designed for easy integration into iOS and macOS apps.

---

## 🧩 Features

- ✅ Simple configuration to add your Komoju API key (`KomojuSDK.shared.configure(apiKey:)`)
- 💳 Credit Card Payments via `makeCreditCardPayment`
- 🪄 Ready-to-use SwiftUI view `KomojuCreditCardFormView`
- 🔒 Input validation for credit card details
- 🌍 Fraud detection via global IP address
- ⛔️ Built-in error handling with user-friendly messages
- 🧪 Fully tested

---

## 📦 Installation

### Swift Package Manager (SPM)

Add **KomojuSDK** to your project via **Xcode**:

1. Go to **File ▸ Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/diogomusou/iOS-Diogo-SDK`
3. Choose **“Up to Next Major Version”** and click **Add Package**.
4. When asked, **Choose Package Products**
    - **KomojuSDK** is the core module
    - **KomojuSDKUI** has ready-to-use SwiftUI views


  Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/diogomusou/iOS-Diogo-SDK.git", from: "1.0.0")
]
...
.target(
    dependencies: [
        .product(name: "KomojuSDK", package: "iOS-Diogo-SDK"),
        .product(name: "KomojuSDKUI", package: "iOS-Diogo-SDK"),
    ]
```
## ⚙️ Configuration

Before making any payments, configure the SDK with your Komoju API key.

It’s recommended to use a **test key** for development and a **live key** for release builds.

  
```swift
import KomojuSDK

@main
struct MyApp: App {
    init() {
#if DEBUG
        KomojuSDK.shared.configure(apiKey: "test_api_key_12345")
#else
        KomojuSDK.shared.configure(apiKey: "live_api_key_ABCDE")
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
✅ **Tip:**

You only need to call configure(apiKey:) **once** — ideally when your app starts.

Subsequent calls are ignored if the SDK is already configured.
## **💳 Making a Payment**

Once configured, you can make a payment using credit card details.

 Example ViewModel Integration:
```
@MainActor
@Observable
final class YourCreditCardFormViewModel {
    var name = ""
    var email = ""
    var cardNumber = ""
    var securityCode = ""
    var expiryMonth = 1
    var expiryYear = 2025

    var didCompletePayment = false
    var error: String?

    func submitButtonTapped() async {
        do {
            try await KomojuSDK.shared.makeCreditCardPayment(
                amount: 5000,
                currency: .JPY,
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
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```
## **🚀 Roadmap / TODOs**

1. Localization: SDK consumer should be able to set the locale and get localized content from
    - KomojuCreditCardFormView
    - KomojuError localizedDescription
2. Additional Komoju API support: the `payments` API has various other parameters that are currently not supported, such as:
    - Billing address
    - Credit Card Brazil/Korea types
3. Better error handling and display: 
    - safely handle all errors
    - make it easy for the consumer to know which field failed
    - in the UI, highlight the fields with errors
4. Better documentation:
    - Document all public code
    - Generate documentation with **DocC** (swift-docc)
5. Support for other architectures: Besides the `async` version of `makeCreditCardPayment`, we could also have other versions for Combine, RxSwift, completion handler, etc
6. Use SwiftGen to make strings and assets type-safe
7. Add Github Actions
    - run tests when code is pushed
    - check test coverage
8. Add feature to use camera to autofill form
9. Add accessibility support (accessibility identifiers, dynamic font, voice over, etc)
10. Improve UI on KomojuCreditCardFormView
    - more customization
    - proper transition after payment is complete
11. Support for older iOS and other OS
12. Re-add swiftlint: I used it as a plugin during development to show warnings/errors when building, but I ended up removing it because of github actions issues.
    
## **🛠 Requirements**

-   iOS 17.0+
-   Swift 5.9+
-   Xcode 15 or later
----------

## **🧾 License**

This SDK is licensed under the [MIT License](LICENSE)
