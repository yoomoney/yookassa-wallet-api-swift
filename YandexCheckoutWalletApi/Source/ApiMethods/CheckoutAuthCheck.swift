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

/// Response for a request of check the authorization code.
public struct CheckoutAuthCheck: Decodable, Encodable {

    /// Output format description of user authorization status
    public let result: AuthTypeState?

    /// Creates instance of CheckoutAuthCheck.
    ///
    /// - Parameters:
    ///     - result: Output format description of user authorization status.
    public init(result: AuthTypeState?) {
        self.result = result
    }

    /// API method for CheckoutAuthCheck.
    public struct Method: Decodable, Encodable {

        /// OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        public let passportAuthorization: String

        /// Merchant client key, issued in merchant's personal account, in the format " Basic [data]".
        public let merchantClientAuthorization: String

        /// The identifier of the authorization context
        let authContextId: String

        /// The type of authorization selected by the user
        let authType: AuthType

        /// The authorization code entered by the user
        let answer: String

        /// Creates instance of CheckoutAuthCheck.Method.
        ///
        /// - Parameters:
        ///     - passportAuthorization: OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        ///     - merchantClientAuthorization:  Merchant client key, issued in merchant's personal account,
        ///                                     in the format " Basic [data]".
        ///   - authContextId: The identifier of the authorization context
        ///   - authType: The type of authorization selected by the user
        ///   - answer: The authorization code entered by the user
        public init(passportAuthorization: String,
                    merchantClientAuthorization: String,
                    authContextId: String,
                    authType: AuthType,
                    answer: String) {
            self.passportAuthorization = passportAuthorization
            self.merchantClientAuthorization = merchantClientAuthorization
            self.authContextId = authContextId
            self.authType = authType
            self.answer = answer
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let authContextId = try container.decode(String.self, forKey: .authContextId)
            let authType = try container.decode(AuthType.self, forKey: .authType)
            let answer = try container.decode(String.self, forKey: .answer)

            self.init(passportAuthorization: "",
                      merchantClientAuthorization: "",
                      authContextId: authContextId,
                      authType: authType,
                      answer: answer)
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(authContextId, forKey: .authContextId)
            try container.encode(authType, forKey: .authType)
            try container.encode(answer, forKey: .answer)
        }

        private enum CodingKeys: String, CodingKey {
            case authContextId
            case authType
            case answer
        }
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let result = try container.decodeIfPresent(AuthTypeState.self, forKey: .result)
        self.init(result: result)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.success, forKey: .status)
        try container.encodeIfPresent(result, forKey: .result)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case result
    }

    private enum Status: String, Decodable, Encodable {
        case success = "Success"
    }
}

// MARK: - JsonApiResponse

extension CheckoutAuthCheck: JsonApiResponse {}

// MARK: - WalletApiResponse

extension CheckoutAuthCheck: WalletApiResponse {
    public static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error? {
        return CheckoutAuthCheckError.makeResponse(response: response, data: data)
    }
}

// MARK: - ApiMethod

extension CheckoutAuthCheck.Method: ApiMethod {

    public typealias Response = CheckoutAuthCheck

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
                           path: "/api/wallet-auth/v1/checkout/auth-check")
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

public enum CheckoutAuthCheckError: String, Decodable, Encodable, JsonApiResponse, WalletErrorApiResponse {

    /// Invalid authorization context.
    case invalidContext

    /// The session has not been created. You must create the session before the authorization check.
    case sessionDoesNotExist

    /// The session has expired, you need to create a new session.
    case sessionExpired

    /// Unsupported authorization type for user.
    case unsupportedAuthType

    /// Ended attempts to enter the code.
    case verifyAttemptsExceeded

    /// The authorization code is invalid.
    case invalidAnswer

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let errorCode = try container.decode(ErrorCode.self, forKey: .error)

        switch errorCode {
        case .invalidContext:
            self = .invalidContext
        case .sessionDoesNotExist:
            self = .sessionDoesNotExist
        case .sessionExpired:
            self = .sessionExpired
        case .unsupportedAuthType:
            self = .unsupportedAuthType
        case .verifyAttemptsExceeded:
            self = .verifyAttemptsExceeded
        case .invalidAnswer:
            self = .invalidAnswer
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.refused, forKey: .status)
        let errorCode: ErrorCode

        switch self {
        case .invalidContext:
            errorCode = .invalidContext
        case .sessionDoesNotExist:
            errorCode = .sessionDoesNotExist
        case .sessionExpired:
            errorCode = .sessionExpired
        case .unsupportedAuthType:
            errorCode = .unsupportedAuthType
        case .verifyAttemptsExceeded:
            errorCode = .verifyAttemptsExceeded
        case .invalidAnswer:
            errorCode = .invalidAnswer
        }

        try container.encode(errorCode, forKey: .error)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case error
    }

    private enum Status: String, Decodable, Encodable {
        case refused = "Refused"
    }

    private enum ErrorCode: String, Decodable, Encodable {
        case invalidContext = "InvalidContext"
        case sessionDoesNotExist = "SessionDoesNotExist"
        case sessionExpired = "SessionExpired"
        case unsupportedAuthType = "UnsupportedAuthType"
        case verifyAttemptsExceeded = "VerifyAttemptsExceeded"
        case invalidAnswer = "InvalidAnswer"
    }
}
