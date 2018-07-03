/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import YandexMoneyCoreApi

/// Generate payment token
public struct CheckoutTokenIssueExecute: Decodable, Encodable {

    /// Main payment token
    public let accessToken: String

    /// Creates instance of CheckoutTokenIssueInit.
    ///
    /// - Parameters:
    ///     - accessToken: Main payment token.
    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    public struct Method: Decodable, Encodable {

        /// OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        public let passportAuthorization: String

        /// Merchant client key, issued in merchant's personal account, in the format " Basic [data]".
        public let merchantClientAuthorization: String

        /// ID the process of obtaining a merchant checkout token payment.
        public let processId: String

        /// Creates instance of CheckoutTokenIssueExecute.Method.
        ///
        /// - Parameters:
        ///     - passportAuthorization: OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        ///     - merchantClientAuthorization:  Merchant client key, issued in merchant's personal account,
        ///                                     in the format " Basic [data]".
        ///     - processId: ID the process of obtaining a merchant checkout token payment.
        public init(passportAuthorization: String,
                    merchantClientAuthorization: String,
                    processId: String) {
            self.passportAuthorization = passportAuthorization
            self.merchantClientAuthorization = merchantClientAuthorization
            self.processId = processId
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let processId = try container.decode(String.self, forKey: .processId)

            self.init(passportAuthorization: "",
                      merchantClientAuthorization: "",
                      processId: processId)
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(processId, forKey: .processId)
        }

        private enum CodingKeys: String, CodingKey {
            case processId
        }
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let resultContainer = try container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        let accessToken = try resultContainer.decode(String.self, forKey: .accessToken)

        self.init(accessToken: accessToken)
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.success, forKey: .status)
        var resultContainer = container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        try resultContainer.encode(accessToken, forKey: .accessToken)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case result
    }

    private enum ResultCodingKeys: String, CodingKey {
        case accessToken
    }

    private enum Status: String, Decodable, Encodable {
        case success = "Success"
    }
}

// MARK: - JsonApiResponse

extension CheckoutTokenIssueExecute: JsonApiResponse {}

// MARK: - WalletApiResponse

extension CheckoutTokenIssueExecute: WalletApiResponse {
    public static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error? {
        return CheckoutTokenIssueExecuteError.makeResponse(response: response, data: data)
    }
}

// MARK: - ApiMethod

extension CheckoutTokenIssueExecute.Method: ApiMethod {

    public typealias Response = CheckoutTokenIssueExecute

    public var hostProviderKey: String {
        return Constants.walletApiMethodsKey
    }

    public var httpMethod: HTTPMethod {
        return .post
    }

    public var parametersEncoding: ParametersEncoding {
        return JsonParametersEncoder()
    }

    public func urlInfo(from hostProvider: HostProvider) throws -> URLInfo {
        return .components(host: try hostProvider.host(for: hostProviderKey),
                           path: "/api/wallet-auth/v1/checkout/token-issue-execute")
    }

    public var headers: Headers {
        let values = [
            AuthorizationConstants.passportAuthorization: AuthorizationConstants.bearerAuthorizationPrefix
                + passportAuthorization,

            AuthorizationConstants.merchantClientAuthorization: AuthorizationConstants.basicAuthorizationPrefix
                + merchantClientAuthorization,

        ]
        return Headers(values)
    }
}

// MARK: - Specific errors
public enum CheckoutTokenIssueExecuteError: Decodable, Encodable, JsonApiResponse, WalletErrorApiResponse {

    /// Failed authorization. The application should proceed to authorization
    case authRequired

    /// The process of issuing a payment token expired or token has already been issued in the framework of
    /// this process.
    case authExpired

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let errorCode = try container.decode(ErrorCode.self, forKey: .error)

        switch errorCode {
        case .authRequired:
            self = .authRequired
        case .authExpired:
            self = .authExpired
        }
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.refused, forKey: .status)

        let errorCode: ErrorCode
        switch self {
        case .authRequired:
            errorCode = .authRequired
        case .authExpired:
            errorCode = .authExpired
        }
        try container.encode(errorCode, forKey: .error)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case error
    }

    private enum ErrorCode: String, Decodable, Encodable {
        case authRequired = "AuthRequired"
        case authExpired = "AuthExpired"
    }

    private enum Status: String, Decodable, Encodable {
        case refused = "Refused"
    }
}
