/*
 * The MIT License
 *
 * Copyright (c) 2007—2018 NBCO Yandex.Money LLC
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

/// The process is initiated with the payment token to the merchant Yandex.Checkout.
public struct CheckoutTokenIssueInit: Decodable, Encodable {

    /// If `status` equal `success`, authRequired will false
    /// If `status` equal `AuthRequired`, authRequired will true
    public let authRequired: Bool

    /// The identifier of the authorization context.
    public let authContextId: String

    /// ID the process of obtaining a merchant checkout token payment.
    public let processId: String

    /// Creates instance of CheckoutTokenIssueInit.
    ///
    /// - Parameters:
    ///     - authContextId: The identifier of the authorization context.
    ///     - processId: ID the process of obtaining a merchant checkout token payment.
    public init(authRequired: Bool,
                authContextId: String,
                processId: String) {
        self.authRequired = authRequired
        self.authContextId = authContextId
        self.processId = processId
    }

    /// API method for CheckoutTokenIssueInit.
    public struct Method: Decodable, Encodable {

        /// OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        public let passportAuthorization: String

        /// Merchant client key, issued in merchant's personal account, in the format " Basic [data]".
        public let merchantClientAuthorization: String

        /// The ID of the authorization instance in the application.
        public let instanceName: String

        /// Amount with currency.
        public let singleAmountMax: MonetaryAmount?

        /// How many times are allowed to pay a generated token: one-time or unlimited.
        public let paymentUsageLimit: PaymentUsageLimit

        /// ThreatMetrix mobile session ID.
        public let tmxSessionId: String

        /// Creates instance of CheckoutTokenIssueInit.Method.
        ///
        /// - Parameters:
        ///     - passportAuthorization: OAuth2 token issued by the Yandex.Passport in the format "Bearer [token]".
        ///     - merchantClientAuthorization:  Merchant client key, issued in merchant's personal account,
        ///                                     in the format " Basic [data]".
        ///     - instanceName: The ID of the authorization instance in the application.
        ///     - singleAmountMax: Amount with currency.
        ///     - paymentUsageLimit: How many times are allowed to pay a generated token: one-time or unlimited.
        ///     - tmxSessionId: ThreatMetrix mobile session ID.
        public init(passportAuthorization: String,
                    merchantClientAuthorization: String,
                    instanceName: String,
                    singleAmountMax: MonetaryAmount?,
                    paymentUsageLimit: PaymentUsageLimit,
                    tmxSessionId: String) {
            self.passportAuthorization = passportAuthorization
            self.merchantClientAuthorization = merchantClientAuthorization
            self.instanceName = instanceName
            self.singleAmountMax = singleAmountMax
            self.paymentUsageLimit = paymentUsageLimit
            self.tmxSessionId = tmxSessionId
        }

        // MARK: - Decodable

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let instanceName = try container.decode(String.self, forKey: .instanceName)
            let singleAmountMax = try container.decodeIfPresent(MonetaryAmount.self, forKey: .singleAmountMax)
            let paymentUsageLimit = try container.decode(PaymentUsageLimit.self, forKey: .paymentUsageLimit)
            let tmxSessionId = try container.decode(String.self, forKey: .tmxSessionId)

            self.init(passportAuthorization: "",
                      merchantClientAuthorization: "",
                      instanceName: instanceName,
                      singleAmountMax: singleAmountMax,
                      paymentUsageLimit: paymentUsageLimit,
                      tmxSessionId: tmxSessionId)
        }

        // MARK: - Encodable

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(instanceName, forKey: .instanceName)
            try container.encodeIfPresent(singleAmountMax, forKey: .singleAmountMax)
            try container.encode(paymentUsageLimit, forKey: .paymentUsageLimit)
            try container.encode(tmxSessionId, forKey: .tmxSessionId)
        }

        private enum CodingKeys: String, CodingKey {
            case instanceName
            case singleAmountMax
            case paymentUsageLimit
            case tmxSessionId
        }
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Status.self, forKey: .status)
        let resultContainer = try container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        let authContextId = try resultContainer.decode(String.self, forKey: .authContextId)
        let processId = try resultContainer.decode(String.self, forKey: .processId)

        let authRequired: Bool
        switch status {
        case .authRequired:
            authRequired = true
        case .success:
            authRequired = false
        }

        self.init(authRequired: authRequired, authContextId: authContextId, processId: processId)
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if authRequired {
            try container.encode(Status.authRequired, forKey: .status)
        } else {
            try container.encode(Status.success, forKey: .status)
        }

        var resultContainer = container.nestedContainer(keyedBy: ResultCodingKeys.self, forKey: .result)
        try resultContainer.encode(authContextId, forKey: .authContextId)
        try resultContainer.encode(processId, forKey: .processId)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case result
    }

    private enum ResultCodingKeys: String, CodingKey {
        case authContextId
        case processId
    }

    private enum Status: String, Decodable, Encodable {
        case success = "Success"
        case authRequired = "AuthRequired"
    }
}

// MARK: - JsonApiResponse

extension CheckoutTokenIssueInit: JsonApiResponse {}

// MARK: - WalletApiResponse

extension CheckoutTokenIssueInit: WalletApiResponse {
    public static func makeSpecificError(response: HTTPURLResponse, data: Data) -> Error? {
        return CheckoutTokenIssueInitError.makeResponse(response: response, data: data)
    }
}

// MARK: - ApiMethod

extension CheckoutTokenIssueInit.Method: ApiMethod {

    public typealias Response = CheckoutTokenIssueInit

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
                           path: "/api/wallet-auth/v1/checkout/token-issue-init")
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

public enum CheckoutTokenIssueInitError: Decodable, Encodable, JsonApiResponse, WalletErrorApiResponse {

    /// There is no user account in Yandex.Money.
    /// The application should proceed to the process of opening the wallet.
    case accountNotFound

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _ = try container.decode(Status.self, forKey: .status)

        let errorCode = try container.decode(ErrorCode.self, forKey: .error)
        switch errorCode {
        case .accountNotFound:
            self = .accountNotFound
        }
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Status.refused, forKey: .status)

        let errorCode: ErrorCode
        switch self {
        case .accountNotFound:
            errorCode = .accountNotFound
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
        case accountNotFound = "AccountNotFound"
    }
}
