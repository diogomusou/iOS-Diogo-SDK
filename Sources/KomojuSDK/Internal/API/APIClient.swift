import Foundation

// TODO: add unit test

protocol APIClient: Sendable {
    func makeIpRequest() async throws -> IpRequestResponse
    func makePaymentRequest(with payment: Payment) async throws -> PaymentRequestResponse
}

enum APIClientError: Error {
    case invalidResponse
    case decodingFailed
    case serverError(FieldAndMessage)
    case network(Error)
}

final actor APIClientLive: APIClient {
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func makePaymentRequest(with payment: Payment) async throws -> PaymentRequestResponse {
        let request = try URLRequest.paymentRequest(with: payment, apiKey: apiKey)
        print("Request curl", request.curlString())

        return try await send(request, decodeTo: PaymentRequestResponse.self)
    }

    func makeIpRequest() async throws -> IpRequestResponse {
        try await send(.ipRequest, decodeTo: IpRequestResponse.self)
    }

    private func send<T: Decodable>(_ request: URLRequest, decodeTo type: T.Type) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            print("Data", String(data: data, encoding: .utf8) ?? "failed")
            print("Response", response)

            guard let http = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }

            if !(200...299).contains(http.statusCode) {
                return try throwServerError(from: data)
            }

            return try JSONDecoder().decode(T.self, from: data)

        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.network(error)
        }
    }

    private func throwServerError<T>(from data: Data) throws -> T {
        if let apiError = try? JSONDecoder().decode(PaymentRequestErrorResponse.self, from: data) {
            let userError = apiError.fieldAndMessage
            throw APIClientError.serverError(userError)
        } else {
            throw APIClientError.decodingFailed
        }
    }
}
