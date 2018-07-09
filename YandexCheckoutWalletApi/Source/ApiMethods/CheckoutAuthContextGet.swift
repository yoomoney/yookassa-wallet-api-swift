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

/// Response for request authorization context api method.
public struct CheckoutAuthContextGet: Decodable, Encodable {

    /// The authorization types of the user.
    public let authTypes: [AuthTypeState]

    /// The default authorization type of the user.
    public let defaultAuthType: AuthType

    /// Creates instance of CheckoutAuthContextGet.
    ///
    /// - Parameters:
    ///     - authTypes: The authorization types of the user.
    ///     - defaultAuthType: The default authorization type of the user.
    public init(authTypes: [AuthTypeState],
                defaultAuthType: AuthType) {
        self.authTypes = authTypes
        self.defaultAuthType = defaultAuthType
    }

    /// API method for CheckoutAuthContextGet.
    public struct Method: Decodable, Encodable {

        /// OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        public let passportAuthorization: String

        /// Merchant client key, issued in merchant's personal account, in the format " Basic [data]".
        public let merchantClientAuthorization: String

        /// The identifier of auth context.
        public let authContextId: String

        /// Creates instance of CheckoutAuthContextGet.Method.
        ///
        /// - Parameters:
        ///     - passportAuthorization: OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        ///     - merchantClientAuthorization:  Merchant client key, issued in merchant's personal account,
        ///                                     in the format " Basic [data]".
        ///     - authContextId: The identifier of the authorization context.
        public init(passportAuthorization: String,
                    merchantClientAuthorization: String,
                    authContextId: String) {
            self.passportAuthorization = passportAuthorization
            self.merchantClientAuthorization = merchantClientAuthorization
            self.authContextId = authContextId
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let authContextId = try container.decode(String.self, forKey: .authContextId)
            self.init(passportAuthorization: "",
                      merchantClientAuthorization: "",
                      authContextId: authContextId)
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(authContextId, forKey: .authContextId)
        }

        private enum CodingKeys: String, CodingKey {
            case authContextId
        }
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        struct Stub: Decodable { }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let resultContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .result)

        var authTypesContainer = try resultContainer.nestedUnkeyedContainer(forKey: .authTypes)
        var authTypes: [AuthTypeState] = []
        authTypes.reserveCapacity(authTypesContainer.count ?? 0)
        while authTypesContainer.isAtEnd != true {
            do {
                let authType = try authTypesContainer.decode(AuthTypeState.self)
                authTypes.append(authType)
            } catch {
                _ = try authTypesContainer.decode(Stub.self)
            }
        }

        let defaultAuthType = try resultContainer.decode(AuthType.self, forKey: .defaultAuthType)

        self.init(authTypes: authTypes, defaultAuthType: defaultAuthType)
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.success, forKey: .status)
        var resultContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .result)
        var authTypesContainer = resultContainer.nestedUnkeyedContainer(forKey: .authTypes)
        for authType in authTypes {
            try authTypesContainer.encode(authType)
        }
        try resultContainer.encode(defaultAuthType, forKey: .defaultAuthType)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case result
        case authTypes
        case defaultAuthType
    }

    private enum Status: String, Decodable, Encodable {
        case success = "Success"
    }
}

// MARK: - JsonApiResponse
extension CheckoutAuthContextGet: JsonApiResponse {}

// MARK: - WalletApiResponse
extension CheckoutAuthContextGet: WalletApiResponse {
    public static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error? {
        return CheckoutAuthContextGetError.makeResponse(response: response, data: data)
    }
}

// MARK: - ApiMethod
extension CheckoutAuthContextGet.Method: ApiMethod {

    public typealias Response = CheckoutAuthContextGet

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
                           path: "/api/wallet-auth/v1/checkout/auth-context-get")
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
public enum CheckoutAuthContextGetError: String, JsonApiResponse, WalletErrorApiResponse, Decodable, Encodable {

    /// Invalid authorization context
    case invalidContext = "InvalidContext"

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)
        let errorCode = try container.decode(ErrorCode.self, forKey: .error)
        switch errorCode {
        case .invalidContext:
            self = .invalidContext
        }
    }

    // MARK: - Encodable

    private enum CodingKeys: String, CodingKey {
        case status
        case error
    }

    private enum Status: String, Decodable, Encodable {
        case refused = "Refused"
    }

    private enum ErrorCode: String, Decodable, Encodable {
        case invalidContext = "InvalidContext"
    }
}
